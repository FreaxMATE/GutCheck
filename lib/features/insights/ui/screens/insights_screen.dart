import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/impact_score.dart';
import '../../providers/insights_providers.dart';
import '../../../pantry/providers/pantry_providers.dart';
import '../../../pantry/ui/widgets/localized_ingredient_name.dart';
import '../../../wellness/domain/wellness_display.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/correlation_scatter_plot.dart';
import '../widgets/food_correlation_heatmap.dart';
import '../widgets/food_fingerprint.dart';
import '../widgets/food_impact_card.dart';
import '../widgets/time_filter_bar.dart';
import '../widgets/timing_analysis_card.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Overview screen — entry point for the Insights tab.
// ══════════════════════════════════════════════════════════════════════════════

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insightsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          const TimeFilterBar(),
          const SizedBox(height: 12),
          const InsightsMetricToggleBar(),
          const SizedBox(height: 16),
          StaggeredEntrance(
            index: 0,
            child: _OverviewCard(
              icon: Icons.calendar_month_rounded,
              title: l10n.insightsTabCalendar,
              subtitle: l10n.insightsCardCalendarSubtitle,
              preview: const _CalendarPreview(),
              onTap: () => context.push('/insights/calendar'),
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntrance(
            index: 1,
            child: _OverviewCard(
              icon: Icons.format_list_bulleted_rounded,
              title: l10n.insightsTabImpact,
              subtitle: l10n.insightsCardImpactSubtitle,
              preview: const _ImpactPreview(),
              onTap: () => context.push('/insights/impact'),
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntrance(
            index: 2,
            child: _OverviewCard(
              icon: Icons.grid_on_rounded,
              title: l10n.insightsTabHeatmap,
              subtitle: l10n.insightsCardHeatmapSubtitle,
              preview: const _HeatmapPreview(),
              onTap: () => context.push('/insights/heatmap'),
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntrance(
            index: 3,
            child: _OverviewCard(
              icon: Icons.fingerprint_rounded,
              title: l10n.insightsTabFingerprint,
              subtitle: l10n.insightsCardFingerprintSubtitle,
              preview: const _FingerprintPreview(),
              onTap: () => context.push('/insights/fingerprint'),
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntrance(
            index: 4,
            child: _OverviewCard(
              icon: Icons.scatter_plot_rounded,
              title: l10n.insightsTabScatter,
              subtitle: l10n.insightsCardScatterSubtitle,
              preview: null,
              onTap: () => context.push('/insights/scatter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? preview;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              if (preview != null) ...[const SizedBox(height: 14), preview!],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Preview widgets for the overview cards ────────────────────────────────────

class _CalendarPreview extends ConsumerWidget {
  const _CalendarPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(heatmapDataProvider);
    return data.maybeWhen(
      data: (scores) {
        if (scores.isEmpty) return const _PreviewEmpty();
        final now = DateTime.now();
        final days = List.generate(7, (i) {
          final d = now.subtract(Duration(days: 6 - i));
          return DateTime(d.year, d.month, d.day);
        });
        return SizedBox(
          height: 44,
          child: Row(
            children: days.map((day) {
              final score = scores[day];
              final color = score != null
                  ? AppColors.wellnessScoreInterpolated(score)
                  : Colors.grey.withValues(alpha: 0.15);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: score != null
                          ? color.withValues(alpha: 0.7)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      score != null ? WellnessDisplay.format(score) : '–',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: score != null ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      orElse: () => const _PreviewLoading(),
    );
  }
}

class _ImpactPreview extends ConsumerWidget {
  const _ImpactPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scores = ref.watch(foodImpactScoresProvider);
    return scores.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const _PreviewEmpty();
        final harmful = items.firstWhere(
          (s) => s.isHarmful,
          orElse: () => items.first,
        );
        final beneficial = items.firstWhere(
          (s) => !s.isHarmful,
          orElse: () => items.first,
        );
        final theme = Theme.of(context);
        return Column(
          children: [
            _MiniImpactRow(
              score: harmful,
              color: Colors.red,
              icon: Icons.warning_amber_rounded,
              suffix: l10n.impactDrop,
              theme: theme,
            ),
            if (harmful.ingredientId != beneficial.ingredientId) ...[
              const SizedBox(height: 6),
              _MiniImpactRow(
                score: beneficial,
                color: Colors.green,
                icon: Icons.check_circle_rounded,
                suffix: l10n.impactImprovement,
                theme: theme,
              ),
            ],
          ],
        );
      },
      orElse: () => const _PreviewLoading(),
    );
  }
}

class _MiniImpactRow extends StatelessWidget {
  final ImpactScore score;
  final Color color;
  final IconData icon;
  final String suffix;
  final ThemeData theme;

  const _MiniImpactRow({
    required this.score,
    required this.color,
    required this.icon,
    required this.suffix,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: LocalizedIngredientText(
            ingredientId: score.ingredientId,
            fallbackName: score.ingredientName,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${score.correlationPercent}% $suffix',
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _HeatmapPreview extends ConsumerWidget {
  const _HeatmapPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scores = ref.watch(foodImpactScoresProvider);
    return scores.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const _PreviewEmpty();
        return Text(
          l10n.insightsCardHeatmapStat(items.length),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        );
      },
      orElse: () => const _PreviewLoading(),
    );
  }
}

class _FingerprintPreview extends ConsumerWidget {
  const _FingerprintPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpData = ref.watch(foodFingerprintProvider);
    return fpData.maybeWhen(
      data: (fingerprints) {
        if (fingerprints.isEmpty) return const _PreviewEmpty();
        final sorted = fingerprints.entries.toList()
          ..sort((a, b) => b.value.dangerScore.compareTo(a.value.dangerScore));
        final top = sorted.first;
        final color = Color.lerp(
          Colors.green,
          Colors.red,
          (top.value.dangerScore / 10).clamp(0.0, 1.0),
        )!;
        return Row(
          children: [
            Icon(Icons.fingerprint_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: LocalizedIngredientText(
                ingredientId: top.key,
                fallbackName: top.value.fallbackName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              top.value.dangerScore.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
      orElse: () => const _PreviewLoading(),
    );
  }
}

class _PreviewEmpty extends StatelessWidget {
  const _PreviewEmpty();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(
      l10n.insightsCardNoData,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 18,
      child: LinearProgressIndicator(minHeight: 2),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Public view widgets — reused by the detail screens (insights_detail_screens).
// ══════════════════════════════════════════════════════════════════════════════

class InsightsCalendarView extends ConsumerWidget {
  const InsightsCalendarView({super.key});

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
          return InsightsEmptyState(
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

class _DayView extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _DayView({required this.scores});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final score = scores[today];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            GutDateUtils.formatDay(today),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: score != null
                  ? AppColors.wellnessScoreInterpolated(
                      score,
                    ).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score != null ? WellnessDisplay.format(score) : '—',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: score != null
                          ? AppColors.wellnessScoreInterpolated(score)
                          : Colors.grey,
                    ),
                  ),
                  if (score != null)
                    Text(
                      WellnessDisplay.suffix,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.wellnessScoreInterpolated(
                          score,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score != null ? l10n.calendarDayScore : l10n.calendarDayNoData,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

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
    // Localized weekday abbreviations (matches current app locale).
    final locale = Localizations.localeOf(context).toString();
    final weekdayFmt = DateFormat('E', locale);

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
              final isToday =
                  day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        weekdayFmt.format(day),
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
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
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            score != null ? WellnessDisplay.format(score) : '',
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

class _YearView extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _YearView({required this.scores});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
      12,
      (i) => DateTime(now.year, now.month - 11 + i, 1),
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: months
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CalendarHeatmap(dailyScores: scores, month: m),
            ),
          )
          .toList(),
    );
  }
}

class InsightsHeatmapView extends ConsumerWidget {
  const InsightsHeatmapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scores = ref.watch(foodImpactScoresProvider);

    return scores.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.genericError(e))),
      data: (items) {
        if (items.isEmpty) {
          return InsightsEmptyState(
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
                l10n.heatmapFoodTimeLag,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.heatmapFoodTimeLagDesc,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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

class InsightsImpactView extends ConsumerWidget {
  const InsightsImpactView({super.key});

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
          return InsightsEmptyState(
            icon: Icons.analytics_outlined,
            message: l10n.insightsImpactEmpty,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
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

class InsightsFingerprintView extends ConsumerWidget {
  const InsightsFingerprintView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final fpData = ref.watch(foodFingerprintProvider);
    final selectedId = ref.watch(selectedFingerprintFoodProvider);

    return fpData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.genericError(e))),
      data: (fingerprints) {
        if (fingerprints.isEmpty) {
          return InsightsEmptyState(
            icon: Icons.fingerprint_rounded,
            message: l10n.insightsFingerprintEmpty,
          );
        }

        final sorted = fingerprints.entries.toList()
          ..sort((a, b) => b.value.dangerScore.compareTo(a.value.dangerScore));

        if (selectedId != null && fingerprints.containsKey(selectedId)) {
          final fp = fingerprints[selectedId]!;
          final name = _resolveIngredientName(
            ref,
            selectedId,
            fp.fallbackName,
            locale,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.insightsScatterPrompt),
                    onPressed: () =>
                        ref
                                .read(selectedFingerprintFoodProvider.notifier)
                                .state =
                            null,
                  ),
                ),
                const SizedBox(height: 8),
                FoodFingerprint(foodName: name, data: fp, size: 260),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (ctx, i) {
            final entry = sorted[i];
            final fp = entry.value;
            final name = _resolveIngredientName(
              ref,
              entry.key,
              fp.fallbackName,
              locale,
            );
            final danger = fp.dangerScore;
            final color = Color.lerp(
              Colors.green,
              Colors.red,
              (danger / 10).clamp(0.0, 1.0),
            )!;

            return StaggeredEntrance(
              index: i,
              baseDelay: const Duration(milliseconds: 30),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(Icons.fingerprint_rounded, color: color),
                  ),
                  title: Text(name),
                  subtitle: Text(
                    'Discomfort ${fp.discomfort.toStringAsFixed(1)} · '
                    'Heartburn ${fp.heartburn.toStringAsFixed(1)} · '
                    '${fp.sampleCount} pts',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      ref.read(selectedFingerprintFoodProvider.notifier).state =
                          entry.key,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _resolveIngredientName(
    WidgetRef ref,
    int ingredientId,
    String fallbackName,
    String locale,
  ) {
    final ingAsync = ref.watch(singleIngredientProvider(ingredientId));
    return ingAsync.maybeWhen(
      data: (ing) => ing?.localizedName(locale) ?? fallbackName,
      orElse: () => fallbackName,
    );
  }
}

class InsightsScatterView extends ConsumerWidget {
  const InsightsScatterView({super.key});

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
            return InsightsEmptyState(
              icon: Icons.scatter_plot_rounded,
              message: l10n.insightsScatterEmpty,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.insightsScatterPrompt,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...items
                  .take(5)
                  .map(
                    (s) => ListTile(
                      title: LocalizedIngredientText(
                        ingredientId: s.ingredientId,
                        fallbackName: s.ingredientName,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          ref.read(selectedImpactScoreProvider.notifier).state =
                              s,
                    ),
                  ),
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
              ref.read(selectedImpactScoreProvider.notifier).state = null;
            },
          ),
          title: LocalizedIngredientText(
            ingredientId: selected.ingredientId,
            fallbackName: selected.ingredientName,
          ),
          subtitle: Text(_localizedImpactSummary(selected, l10n)),
        ),
        const Divider(),
        Expanded(
          child: heatmap.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.genericError(e))),
            data: (dailyScores) => mealTimes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                  ingredientId: selected.ingredientId,
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

// ── Shared helpers (public) ───────────────────────────────────────────────────

class InsightsEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const InsightsEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightsMetricToggleBar extends ConsumerWidget {
  const InsightsMetricToggleBar({super.key});

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
            value: WellnessMetric.stress,
            label: Text(l10n.insightsMetricStress),
            icon: const Icon(Icons.psychology_rounded),
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
  final direction = score.isHarmful ? l10n.impactDrop : l10n.impactImprovement;
  final lag = score.bestZone.shortLabel;
  return l10n.impactSummary(pct, direction, lag);
}
