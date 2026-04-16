import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../domain/impact_score.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../providers/insights_providers.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/correlation_scatter_plot.dart';
import '../widgets/food_correlation_heatmap.dart';
import '../widgets/food_impact_card.dart';
import '../widgets/time_filter_bar.dart';
import '../widgets/timing_analysis_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.insightsTitle),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.calendar_month_rounded), text: l10n.insightsTabCalendar),
              Tab(icon: const Icon(Icons.grid_on_rounded), text: l10n.insightsTabHeatmap),
              Tab(icon: const Icon(Icons.format_list_bulleted_rounded), text: l10n.insightsTabImpact),
              Tab(icon: const Icon(Icons.scatter_plot_rounded), text: l10n.insightsTabScatter),
            ],
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: TimeFilterBar(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _MetricToggleBar(),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _CalendarTab(),
                  _HeatmapTab(),
                  _ImpactTab(),
                  _ScatterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calendar Tab (adapts layout to the selected time filter) ─────────────────

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(insightsTimeFilterProvider);
    final data = ref.watch(heatmapDataProvider);

    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.genericError(e))),
      data: (scores) {
        if (scores.isEmpty) {
          return _EmptyState(
            icon: Icons.calendar_month_rounded,
            message: l10n.insightsCalendarEmpty,
          );
        }

        return switch (filter) {
          TimeFilter.day => _DayView(scores: scores),
          TimeFilter.week => _WeekView(scores: scores),
          TimeFilter.month => _MonthView(scores: scores),
          TimeFilter.year => _YearView(scores: scores),
        };
      },
    );
  }
}

/// Day filter: show today's single score as a large ring.
class _DayView extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _DayView({required this.scores});

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final score = scores[today];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(GutDateUtils.formatDay(today),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: score != null
                  ? AppColors.wellnessScoreInterpolated(score)
                      .withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                score != null ? score.round().toString() : '—',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: score != null
                      ? AppColors.wellnessScoreInterpolated(score)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score != null ? 'wellness score' : 'No data today',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Week filter: show 7 days as a horizontal strip.
class _WeekView extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _WeekView({required this.scores});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: days.map((day) {
              final score = scores[day];
              final color = score != null
                  ? AppColors.wellnessScoreInterpolated(score)
                  : Colors.grey.withValues(alpha: 0.15);
              final isToday = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        weekdayLabels[day.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: score != null ? 40 + (score / 100) * 80 : 40,
                        decoration: BoxDecoration(
                          color: score != null
                              ? color.withValues(alpha: 0.7)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            score != null ? '${score.round()}' : '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: score != null
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Month filter: single current-month calendar grid.
class _MonthView extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _MonthView({required this.scores});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        CalendarHeatmap(
          dailyScores: scores,
          month: DateTime(DateTime.now().year, DateTime.now().month, 1),
        ),
      ],
    );
  }
}

/// Year filter: 12 months of calendar grids.
class _YearView extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _YearView({required this.scores});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
        12, (i) => DateTime(now.year, now.month - 11 + i, 1));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: months
          .map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: CalendarHeatmap(dailyScores: scores, month: m),
              ))
          .toList(),
    );
  }
}

// ── Heatmap Tab (food × lag correlation matrix) ───────────────────────────────

class _HeatmapTab extends ConsumerWidget {
  const _HeatmapTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scores = ref.watch(foodImpactScoresProvider);

    return scores.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.genericError(e))),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.grid_on_rounded,
            message: l10n.insightsHeatmapEmpty,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Food × Time Lag',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Pearson r correlation between food consumption and wellness at each lag window',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              FoodCorrelationHeatmap(scores: items),
            ],
          ),
        );
      },
    );
  }
}

// ── Impact Tab ────────────────────────────────────────────────────────────────

class _ImpactTab extends ConsumerWidget {
  const _ImpactTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scores = ref.watch(foodImpactScoresProvider);

    final timing = ref.watch(timingAnalysisProvider);

    return scores.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.genericError(e))),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.analytics_outlined,
            message: l10n.insightsImpactEmpty,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          // +1 for the timing analysis card at the top.
          itemCount: items.length + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) {
              return timing.maybeWhen(
                data: (analysis) => analysis.buckets.isNotEmpty
                    ? StaggeredEntrance(
                        index: 0,
                        baseDelay: const Duration(milliseconds: 30),
                        child: TimingAnalysisCard(analysis: analysis),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              );
            }
            return StaggeredEntrance(
              index: i,
              baseDelay: const Duration(milliseconds: 30),
              child: FoodImpactCard(score: items[i - 1]),
            );
          },
        );
      },
    );
  }
}

// ── Scatter Tab ───────────────────────────────────────────────────────────────

class _ScatterTab extends ConsumerWidget {
  const _ScatterTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedImpactScoreProvider);
    final scores = ref.watch(foodImpactScoresProvider);
    final heatmap = ref.watch(heatmapDataProvider);
    final mealTimes = ref.watch(selectedIngredientMealTimesProvider);

    if (selected == null) {
      return scores.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError(e))),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyState(
              icon: Icons.scatter_plot_rounded,
              message: l10n.insightsScatterEmpty,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.insightsScatterPrompt,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...items.take(5).map((s) => ListTile(
                    title: Text(s.ingredientName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ref
                        .read(selectedImpactScoreProvider.notifier)
                        .state = s,
                  )),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Clear the selected item to return to scatter list
              ref.read(selectedImpactScoreProvider.notifier).state = null;
            },
          ),
          title: Text(selected.ingredientName),
          subtitle: Text(_localizedImpactSummary(selected, l10n)),
        ),
        const Divider(),
        Expanded(
          child: heatmap.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.genericError(e))),
            data: (dailyScores) => mealTimes.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.genericError(e))),
              data: (times) {
                final median = dailyScores.isEmpty
                    ? 50.0
                    : dailyScores.values.reduce((a, b) => a + b) /
                        dailyScores.length;
                final spots = CorrelationScatterPlot.buildSpots(
                  mealTimes: times,
                  dailyScores: dailyScores,
                  color: selected.isHarmful ? Colors.red : Colors.green,
                );
                return CorrelationScatterPlot(
                  ingredientName: selected.ingredientName,
                  spots: spots,
                  medianScore: median,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PulseIcon(icon: icon, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// ── Metric Toggle Bar ─────────────────────────────────────────────────────────

class _MetricToggleBar extends ConsumerWidget {
  const _MetricToggleBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(insightsMetricProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<WellnessMetric>(
        segments: [
          ButtonSegment(
            value: WellnessMetric.gutPeace,
            label: Text(l10n.insightsMetricGutPeace),
            icon: const Icon(Icons.sentiment_satisfied_rounded),
          ),
          ButtonSegment(
            value: WellnessMetric.heartburn,
            label: Text(l10n.insightsMetricHeartburn),
            icon: const Icon(Icons.local_fire_department_rounded),
          ),
          ButtonSegment(
            value: WellnessMetric.diarrhea,
            label: Text(l10n.insightsMetricDiarrhea),
            icon: const Icon(Icons.water_drop_rounded),
          ),
          ButtonSegment(
            value: WellnessMetric.combined,
            label: Text(l10n.insightsMetricCombined),
            icon: const Icon(Icons.analytics_rounded),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (s) =>
            ref.read(insightsMetricProvider.notifier).state = s.first,
      ),
    );
  }
}

String _localizedImpactSummary(ImpactScore score, AppLocalizations l10n) {
  if (score.sampleCount < 3) return l10n.impactNotEnoughData;
  final pct = score.correlationPercent;
  final direction =
      score.isHarmful ? l10n.impactDrop : l10n.impactImprovement;
  // Use zone short label (e.g. "0–4h") instead of raw hours.
  final lag = score.bestZone.shortLabel;
  return l10n.impactSummary(pct, direction, lag);
}
