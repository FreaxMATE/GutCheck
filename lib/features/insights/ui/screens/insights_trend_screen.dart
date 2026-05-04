import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../wellness/domain/wellness_display.dart';
import '../../providers/insights_providers.dart';
import 'insights_screen.dart' show InsightsEmptyState;

/// Computes a centred rolling 7-day moving average over a list of (day, score)
/// points. Returns one MA point per input day. The window includes the current
/// day plus up to 6 trailing days; if fewer than 3 points fall in the window,
/// the result is null for that day (skipped on the chart).
List<({DateTime day, double? ma})> rolling7dMA(
  List<({DateTime day, double score})> series,
) {
  final out = <({DateTime day, double? ma})>[];
  for (var i = 0; i < series.length; i++) {
    final anchor = series[i].day;
    final from = anchor.subtract(const Duration(days: 6));
    double sum = 0;
    int count = 0;
    for (var j = i; j >= 0; j--) {
      final p = series[j];
      if (p.day.isBefore(from)) break;
      sum += p.score;
      count += 1;
    }
    out.add((day: anchor, ma: count >= 3 ? sum / count : null));
  }
  return out;
}

/// Visible spans (in days) at which raw entry dots are fully shown / fully
/// hidden. Between these two thresholds, dot opacity fades linearly so the
/// transition isn't a hard pop as the user zooms.
const double _rawDotsFullyShownAt = 25;
const double _rawDotsFullyHiddenAt = 35;

/// Smallest visible window the user can zoom into. Prevents zooming past the
/// point where the chart has nothing left to show.
const double _minVisibleSpanDays = 1.0;

/// Rubber-band feel when dragging past the data extent: only this fraction of
/// the overshoot is honoured visually, capped at this many days.
const double _rubberFactor = 0.4;
const double _rubberMaxOvershootDays = 14;

/// Velocity below which a release is treated as "no fling".
const double _flingMinVelocityPxPerSec = 80;

/// Approximate width reserved for the left (y-axis) labels — used to convert
/// gesture pixel positions into chart x-coordinates.
const double _leftAxisReservedPx = 32;

class InsightsTrendView extends ConsumerStatefulWidget {
  const InsightsTrendView({super.key});

  @override
  ConsumerState<InsightsTrendView> createState() => _InsightsTrendViewState();
}

class _InsightsTrendViewState extends ConsumerState<InsightsTrendView>
    with TickerProviderStateMixin {
  // Visible window in chart x-coordinates (days from anchorDay).
  double _minX = 0;
  double _maxX = 1;

  // Total data extent — recomputed when data changes.
  double _totalMinX = 0;
  double _totalMaxX = 1;
  bool _initialized = false;

  // Cached chart widget width (full container, including left axis area).
  double _chartWidthPx = 1;

  // Snapshot taken at scale-gesture start.
  double _gestureStartMinX = 0;
  double _gestureStartMaxX = 0;
  double _gestureStartFocalChartX = 0;

  // Animation controllers: one for momentum flings, one for tween snaps
  // (rubber-band release, double-tap reset).
  late final AnimationController _flingCtrl;
  late final AnimationController _snapCtrl;
  double _flingStartMinX = 0;
  double _flingStartMaxX = 0;
  double _snapFromMin = 0, _snapFromMax = 0;
  double _snapToMin = 0, _snapToMax = 0;

  @override
  void initState() {
    super.initState();
    _flingCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(_onFlingTick);
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(_onSnapTick);
  }

  @override
  void dispose() {
    _flingCtrl
      ..removeListener(_onFlingTick)
      ..dispose();
    _snapCtrl
      ..removeListener(_onSnapTick)
      ..dispose();
    super.dispose();
  }

  // Linear 0..1 fade for raw entry dot opacity.
  double get _rawDotsOpacity {
    final span = _maxX - _minX;
    if (span <= _rawDotsFullyShownAt) return 1.0;
    if (span >= _rawDotsFullyHiddenAt) return 0.0;
    return 1 -
        (span - _rawDotsFullyShownAt) /
            (_rawDotsFullyHiddenAt - _rawDotsFullyShownAt);
  }

  void _stopAnimations() {
    if (_flingCtrl.isAnimating) _flingCtrl.stop();
    if (_snapCtrl.isAnimating) _snapCtrl.stop();
  }

  // Plot-area x-ratio (0..1) for a pixel position in the gesture detector.
  double _focalRatio(double localPx) {
    final plotPx =
        (_chartWidthPx - _leftAxisReservedPx).clamp(1.0, double.infinity);
    return ((localPx - _leftAxisReservedPx) / plotPx).clamp(0.0, 1.0);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _stopAnimations();
    _gestureStartMinX = _minX;
    _gestureStartMaxX = _maxX;
    final ratio = _focalRatio(details.localFocalPoint.dx);
    _gestureStartFocalChartX =
        _gestureStartMinX + ratio * (_gestureStartMaxX - _gestureStartMinX);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scale = details.scale.clamp(0.05, 100.0);
    final startSpan = _gestureStartMaxX - _gestureStartMinX;
    final maxSpan = _totalMaxX - _totalMinX;
    var newSpan = startSpan / scale;
    if (newSpan < _minVisibleSpanDays) newSpan = _minVisibleSpanDays;

    // Anchor the chart point that was under the focal point at gesture-start
    // to the focal point's *current* pixel position (this gives both pinch-
    // around-focus and pan-by-translation in one calculation).
    final ratio = _focalRatio(details.localFocalPoint.dx);
    var newMin = _gestureStartFocalChartX - ratio * newSpan;
    var newMax = newMin + newSpan;

    // Edge resistance — only meaningful while zoomed in past the full extent.
    if (newSpan <= maxSpan) {
      if (newMin < _totalMinX) {
        final overshoot =
            (_totalMinX - newMin).clamp(0.0, _rubberMaxOvershootDays);
        newMin = _totalMinX - overshoot * _rubberFactor;
        newMax = newMin + newSpan;
      } else if (newMax > _totalMaxX) {
        final overshoot =
            (newMax - _totalMaxX).clamp(0.0, _rubberMaxOvershootDays);
        newMax = _totalMaxX + overshoot * _rubberFactor;
        newMin = newMax - newSpan;
      }
    }

    setState(() {
      _minX = newMin;
      _maxX = newMax;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    final span = _maxX - _minX;
    final maxSpan = _totalMaxX - _totalMinX;

    // Snap-back if the gesture left us out of bounds (rubber-band release or
    // zoomed past full extent).
    if (span > maxSpan) {
      _snapTo(_totalMinX, _totalMaxX);
      return;
    }
    if (_minX < _totalMinX) {
      _snapTo(_totalMinX, _totalMinX + span);
      return;
    }
    if (_maxX > _totalMaxX) {
      _snapTo(_totalMaxX - span, _totalMaxX);
      return;
    }

    // Otherwise, fling on horizontal release velocity.
    final vxPx = details.velocity.pixelsPerSecond.dx;
    if (vxPx.abs() < _flingMinVelocityPxPerSec) return;
    final plotPx =
        (_chartWidthPx - _leftAxisReservedPx).clamp(1.0, double.infinity);
    final pxPerChartUnit = plotPx / span;
    // Drag right (vx > 0) reveals earlier data, i.e. minX decreases.
    final velocityChartPerSec = -vxPx / pxPerChartUnit;
    _startFling(velocityChartPerSec);
  }

  void _onDoubleTap() {
    _stopAnimations();
    if (_minX == _totalMinX && _maxX == _totalMaxX) return;
    _snapTo(_totalMinX, _totalMaxX);
  }

  void _startFling(double velocityChartPerSec) {
    _flingStartMinX = _minX;
    _flingStartMaxX = _maxX;
    _flingCtrl
      ..value = 0
      ..animateWith(FrictionSimulation(0.135, 0, velocityChartPerSec));
  }

  void _onFlingTick() {
    final delta = _flingCtrl.value;
    final span = _flingStartMaxX - _flingStartMinX;
    var newMin = _flingStartMinX + delta;
    var newMax = newMin + span;
    // Hard-stop at extents — no rubber-band on fling, just clamp and halt.
    if (newMin < _totalMinX) {
      newMin = _totalMinX;
      newMax = newMin + span;
      _flingCtrl.stop();
    } else if (newMax > _totalMaxX) {
      newMax = _totalMaxX;
      newMin = newMax - span;
      _flingCtrl.stop();
    }
    setState(() {
      _minX = newMin;
      _maxX = newMax;
    });
  }

  void _snapTo(double toMin, double toMax) {
    _snapFromMin = _minX;
    _snapFromMax = _maxX;
    _snapToMin = toMin;
    _snapToMax = toMax;
    _snapCtrl.forward(from: 0);
  }

  void _onSnapTick() {
    final t = Curves.easeOutCubic.transform(_snapCtrl.value);
    setState(() {
      _minX = _snapFromMin + (_snapToMin - _snapFromMin) * t;
      _maxX = _snapFromMax + (_snapToMax - _snapFromMax) * t;
    });
  }

  // Initialise/extend the visible window when data first loads or grows.
  void _syncWindowToData(double newTotalMin, double newTotalMax) {
    if (!_initialized) {
      _totalMinX = newTotalMin;
      _totalMaxX = newTotalMax;
      _minX = newTotalMin;
      _maxX = newTotalMax;
      _initialized = true;
      return;
    }
    final wasFullyZoomedOut =
        (_minX - _totalMinX).abs() < 1e-6 && (_maxX - _totalMaxX).abs() < 1e-6;
    _totalMinX = newTotalMin;
    _totalMaxX = newTotalMax;
    if (wasFullyZoomedOut) {
      _minX = newTotalMin;
      _maxX = newTotalMax;
    } else {
      // Keep current window but clamp to new bounds.
      if (_minX < _totalMinX) _minX = _totalMinX;
      if (_maxX > _totalMaxX) _maxX = _totalMaxX;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dailyAsync = ref.watch(wellnessDailySeriesProvider);
    final entriesAsync = ref.watch(wellnessEntrySeriesProvider);

    if (dailyAsync.isLoading || entriesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (dailyAsync.hasError) {
      return Center(child: Text(l10n.genericError(dailyAsync.error!)));
    }
    if (entriesAsync.hasError) {
      return Center(child: Text(l10n.genericError(entriesAsync.error!)));
    }
    final daily = dailyAsync.value!;
    final entries = entriesAsync.value!;
    if (daily.isEmpty || entries.isEmpty) {
      return InsightsEmptyState(
        icon: Icons.show_chart_rounded,
        message: l10n.insightsTrendEmpty,
      );
    }

    final theme = Theme.of(context);

    // x-axis is days since the anchor (date-only) for daily-aggregated points,
    // or fractional days for individual entries.
    final anchor = entries.first.t;
    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);
    double xOfDay(DateTime d) =>
        DateTime(d.year, d.month, d.day).difference(anchorDay).inDays
            .toDouble();
    double xOfTime(DateTime d) =>
        d.difference(anchorDay).inMilliseconds /
        const Duration(days: 1).inMilliseconds;

    final entrySpots = [
      for (final p in entries) FlSpot(xOfTime(p.t), p.score),
    ];
    final dailySpots = [
      for (final p in daily) FlSpot(xOfDay(p.day), p.score),
    ];
    final ma = rolling7dMA(daily);
    final maSpots = [
      for (final p in ma)
        if (p.ma != null) FlSpot(xOfDay(p.day), p.ma!),
    ];

    final dataMaxX = entrySpots.last.x == 0 ? 1.0 : entrySpots.last.x;
    _syncWindowToData(entrySpots.first.x, dataMaxX);

    // Adapt x-axis label step & format to the visible span.
    final visSpan = (_maxX - _minX).round().clamp(1, 100000);
    final labelStep = visSpan <= 14
        ? 2
        : visSpan <= 60
            ? 7
            : visSpan <= 180
                ? 30
                : 60;
    final locale = Localizations.localeOf(context).toString();
    final DateFormat dateFmt = visSpan <= 14
        ? DateFormat('E d', locale)
        : visSpan <= 180
            ? DateFormat.MMMd(locale)
            : DateFormat.yMMM(locale);

    final rawOpacity = _rawDotsOpacity;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (rawOpacity > 0.05)
                  _LegendDot(
                    color: AppColors.wellnessGreen
                        .withValues(alpha: 0.55 * rawOpacity),
                    label: l10n.insightsTrendEntries,
                  ),
                _LegendDot(
                  color: Colors.grey.shade500,
                  label: l10n.insightsTrendRawSeries,
                ),
                _LegendDot(
                  color: AppColors.wellnessGreen,
                  label: l10n.insightsTrend7dAvg,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _chartWidthPx = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  onDoubleTap: _onDoubleTap,
                  child: LineChart(
                    LineChartData(
                      minX: _minX,
                      maxX: _maxX,
                      minY: 0,
                      maxY: 100,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 25,
                            reservedSize: _leftAxisReservedPx,
                            getTitlesWidget: (v, meta) => Text(
                              WellnessDisplay.format(v),
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: labelStep.toDouble(),
                            reservedSize: 28,
                            getTitlesWidget: (v, meta) {
                              // Skip labels outside the visible window so
                              // edges don't show stale ticks during a fling.
                              if (v < _minX - 0.5 || v > _maxX + 0.5) {
                                return const SizedBox.shrink();
                              }
                              final d =
                                  anchorDay.add(Duration(days: v.round()));
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  dateFmt.format(d),
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Disable fl_chart's interactive tooltip — gestures
                      // own all touches in this view.
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        // Daily averages — thin grey, beneath everything.
                        LineChartBarData(
                          spots: dailySpots,
                          isCurved: false,
                          color: Colors.grey.shade500,
                          barWidth: 1.2,
                          dotData: const FlDotData(show: false),
                        ),
                        // 7-day moving average — thick green, on top.
                        if (maSpots.length >= 2)
                          LineChartBarData(
                            spots: maSpots,
                            isCurved: true,
                            curveSmoothness: 0.25,
                            color: AppColors.wellnessGreen,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        // Individual entries — score-coloured dots that fade
                        // in/out smoothly as zoom crosses the threshold.
                        if (rawOpacity > 0.01)
                          LineChartBarData(
                            spots: entrySpots,
                            isCurved: false,
                            color: Colors.transparent,
                            barWidth: 0,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) =>
                                  FlDotCirclePainter(
                                radius: 2.5,
                                color: AppColors.wellnessScoreInterpolated(
                                  spot.y,
                                ).withValues(alpha: rawOpacity),
                                strokeWidth: 0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              l10n.insightsTrendZoomHint,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// Compact sparkline used on the home dashboard.
///
/// If [from]/[to] are provided, the x-axis is fixed to that window (so empty
/// days at the edges still take up space). Otherwise the line stretches between
/// the first and last point. If [dayMarkers] are provided, a subtle row of
/// short day-letter labels is rendered beneath the chart at proportional
/// x-positions. Plays a one-shot left-to-right draw-in animation on first
/// appearance (gated by [animationsEnabledProvider]).
class WellnessSparkline extends ConsumerStatefulWidget {
  final List<({DateTime t, double score})> points;
  final double height;
  final DateTime? from;
  final DateTime? to;
  final List<DateTime>? dayMarkers;

  const WellnessSparkline({
    super.key,
    required this.points,
    this.height = 48,
    this.from,
    this.to,
    this.dayMarkers,
  });

  @override
  ConsumerState<WellnessSparkline> createState() => _WellnessSparklineState();
}

class _WellnessSparklineState extends ConsumerState<WellnessSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final enabled = ref.read(animationsEnabledProvider);
      if (enabled) {
        _draw.forward();
      } else {
        _draw.value = 1;
      }
    });
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final from = widget.from;
    final to = widget.to;
    final dayMarkers = widget.dayMarkers;
    final height = widget.height;
    final hasMarkers = dayMarkers != null && dayMarkers.isNotEmpty;
    if (points.length < 2) {
      return SizedBox(height: height + (hasMarkers ? 14 : 0));
    }
    final firstMs =
        (from ?? points.first.t).millisecondsSinceEpoch.toDouble();
    final lastMs = (to ?? points.last.t).millisecondsSinceEpoch.toDouble();
    final span = (lastMs - firstMs).clamp(1.0, double.infinity);
    final spots = [
      for (final p in points)
        FlSpot(
          ((p.t.millisecondsSinceEpoch - firstMs) / span).clamp(0.0, 1.0),
          p.score,
        ),
    ];

    final chartCore = LineChart(
      LineChartData(
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.wellnessGreen,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 2,
                color: AppColors.wellnessScoreInterpolated(spot.y),
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.wellnessGreen.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
    final chart = SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: _draw,
        builder: (_, __) => ClipRect(
          clipper: _RevealClipper(progress: _draw.value),
          child: chartCore,
        ),
      ),
    );

    if (!hasMarkers) return chart;

    final locale = Localizations.localeOf(context).toString();
    final letterFmt = DateFormat('EEEEE', locale);
    final today = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day;

    return Column(
      children: [
        chart,
        const SizedBox(height: 4),
        SizedBox(
          height: 12,
          child: Row(
            children: [
              for (final d in dayMarkers)
                Expanded(
                  child: Text(
                    letterFmt.format(d),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday(d)
                          ? Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.7),
                      fontWeight:
                          isToday(d) ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  final double progress;
  const _RevealClipper({required this.progress});

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * progress.clamp(0.0, 1.0), size.height);

  @override
  bool shouldReclip(_RevealClipper old) => old.progress != progress;
}

class InsightsTrendScreen extends StatelessWidget {
  const InsightsTrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTabTrend)),
      body: const InsightsTrendView(),
    );
  }
}
