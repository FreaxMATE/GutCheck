import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

/// Above this many entries, the trend view aggregates by day; below it, every
/// individual entry is plotted as its own point.
const int _perEntryThreshold = 60;

class InsightsTrendView extends ConsumerWidget {
  const InsightsTrendView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final usePerEntry = entries.length <= _perEntryThreshold;
    final rawPoints = usePerEntry
        ? entries
        : [for (final p in daily) (t: p.day, score: p.score)];
    return _TrendChart(
      rawPoints: rawPoints,
      dailyForMA: daily,
      perEntry: usePerEntry,
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<({DateTime t, double score})> rawPoints;
  final List<({DateTime day, double score})> dailyForMA;
  final bool perEntry;
  const _TrendChart({
    required this.rawPoints,
    required this.dailyForMA,
    required this.perEntry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ma = rolling7dMA(dailyForMA);

    // Anchor x-axis at the earliest of (raw, MA) — usually rawPoints.first.t.
    final anchor = rawPoints.first.t;
    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);
    double xOfDay(DateTime d) =>
        DateTime(d.year, d.month, d.day).difference(anchorDay).inDays
            .toDouble();
    double xOfTime(DateTime d) =>
        d.difference(anchorDay).inMilliseconds /
        const Duration(days: 1).inMilliseconds;

    final rawSpots = [
      for (final p in rawPoints) FlSpot(xOfTime(p.t), p.score),
    ];
    final maSpots = [
      for (final p in ma)
        if (p.ma != null) FlSpot(xOfDay(p.day), p.ma!),
    ];

    final maxX = rawSpots.last.x;
    final spanDays = maxX.toInt();
    // Aim for ~5 x-axis labels; format adapts with span.
    final step = spanDays <= 14
        ? 2
        : spanDays <= 60
            ? 7
            : spanDays <= 180
                ? 30
                : 60;
    final locale = Localizations.localeOf(context).toString();
    final DateFormat dateFmt = spanDays <= 14
        ? DateFormat('E d', locale)
        : spanDays <= 180
            ? DateFormat.MMMd(locale)
            : DateFormat.yMMM(locale);

    String fmtTooltipDate(double x) {
      final d = anchorDay.add(Duration(days: x.round()));
      return spanDays <= 14
          ? DateFormat.MMMd(locale).format(d)
          : DateFormat.yMMMd(locale).format(d);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 16,
              children: [
                _LegendDot(
                  color: Colors.grey.shade400,
                  label: perEntry
                      ? l10n.insightsTrendEntries
                      : l10n.insightsTrendRawSeries,
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
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX == 0 ? 1 : maxX,
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
                      reservedSize: 32,
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
                      interval: step.toDouble(),
                      reservedSize: 28,
                      getTitlesWidget: (v, meta) {
                        final d = anchorDay.add(Duration(days: v.round()));
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surface.withValues(alpha: 0.95),
                    tooltipBorder: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    getTooltipItems: (touched) => [
                      for (final spot in touched)
                        LineTooltipItem(
                          '${WellnessDisplay.format(spot.y)}'
                          '${WellnessDisplay.suffix}\n'
                          '${fmtTooltipDate(spot.x)}',
                          theme.textTheme.bodySmall?.copyWith(
                                color: spot.barIndex == 0
                                    ? Colors.grey.shade700
                                    : AppColors.wellnessGreen,
                                fontWeight: FontWeight.w600,
                              ) ??
                              const TextStyle(),
                        ),
                    ],
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: rawSpots,
                    isCurved: false,
                    color: Colors.grey.shade400,
                    barWidth: 1.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: 2.5,
                        color: AppColors.wellnessScoreInterpolated(spot.y),
                        strokeWidth: 0,
                      ),
                    ),
                  ),
                  if (maSpots.length >= 2)
                    LineChartBarData(
                      spots: maSpots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: AppColors.wellnessGreen,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                ],
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
