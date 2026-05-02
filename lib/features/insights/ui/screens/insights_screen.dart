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
import 'insights_trend_screen.dart' show WellnessSparkline;
import '../widgets/correlation_scatter_plot.dart';
import '../widgets/food_correlation_heatmap.dart';
import '../widgets/food_fingerprint.dart';
import '../widgets/food_impact_card.dart';
import '../widgets/stress_impact_card.dart';
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
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: l10n.insightsHowItWorksTitle,
            onPressed: () => _showHowItWorks(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
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
              onLongPress: () => _showCalendarDensityMenu(context, ref, l10n),
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
          const SizedBox(height: 12),
          StaggeredEntrance(
            index: 5,
            child: _OverviewCard(
              icon: Icons.show_chart_rounded,
              title: l10n.insightsTabTrend,
              subtitle: l10n.insightsCardTrendSubtitle,
              preview: const _TrendPreview(),
              onTap: () => context.push('/insights/trend'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showHowItWorks(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              Text(
                l10n.insightsHowItWorksTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.insightsHowItWorksLead,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              _HelpSection(
                icon: Icons.analytics_rounded,
                title: l10n.insightsHelpCombinedTitle,
                body: l10n.insightsHelpCombinedBody,
              ),
              const SizedBox(height: 16),
              _HelpSection(
                icon: Icons.query_stats_rounded,
                title: l10n.insightsHelpCorrelationTitle,
                body: l10n.insightsHelpCorrelationBody,
              ),
              const SizedBox(height: 16),
              _HelpSection(
                icon: Icons.psychology_rounded,
                title: l10n.insightsHelpStressTitle,
                body: l10n.insightsHelpStressBody,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.insightsHelpCaveat,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCalendarDensityMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final current = ref.read(insightsCalendarRangeProvider);
    const options = [TimeFilter.day, TimeFilter.week, TimeFilter.month];
    final picked = await showModalBottomSheet<TimeFilter>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.insightsCalendarDensityTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            ),
            RadioGroup<TimeFilter>(
              groupValue: current,
              onChanged: (v) {
                if (v != null) Navigator.of(ctx).pop(v);
              },
              child: Column(
                children: [
                  for (final o in options)
                    RadioListTile<TimeFilter>(
                      value: o,
                      title: Text(
                        switch (o) {
                          TimeFilter.day => l10n.timeFilterDay,
                          TimeFilter.week => l10n.timeFilterWeek,
                          TimeFilter.month => l10n.timeFilterMonth,
                          TimeFilter.year => '',
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      ref.read(insightsCalendarRangeProvider.notifier).state = picked;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? preview;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
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
    final range = ref.watch(insightsCalendarRangeProvider);
    return data.maybeWhen(
      data: (scores) {
        if (scores.isEmpty) return const _PreviewEmpty();
        return switch (range) {
          TimeFilter.day => _DayTile(scores: scores),
          TimeFilter.week => _WeekStrip(scores: scores),
          TimeFilter.month || TimeFilter.year =>
            _MonthGrid(scores: scores),
        };
      },
      orElse: () => const _PreviewLoading(),
    );
  }
}

/// Single big tile with today's wellness score. Used when the user sets the
/// card density to "Day" via long-press.
class _DayTile extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _DayTile({required this.scores});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final score = scores[key];
    final color = score != null
        ? AppColors.wellnessScoreInterpolated(score)
        : Colors.grey;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: score != null
            ? color.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score != null ? WellnessDisplay.format(score) : '–',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: score != null ? color : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            score != null ? l10n.calendarDayScore : l10n.calendarDayNoData,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _WeekStrip({required this.scores});

  @override
  Widget build(BuildContext context) {
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
  }
}

class _MonthGrid extends StatelessWidget {
  final Map<DateTime, double> scores;
  const _MonthGrid({required this.scores});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return CalendarHeatmap(
      dailyScores: scores,
      month: DateTime(now.year, now.month, 1),
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

class _GroupedRadar extends StatelessWidget {
  final String title;
  final Color accent;
  final List<FingerprintLayer> layers;
  final List<String> axisLabels;
  final double size;

  const _GroupedRadar({
    required this.title,
    required this.accent,
    required this.layers,
    required this.axisLabels,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
        ),
        const SizedBox(height: 10),
        layers.isEmpty
            ? SizedBox(
                height: size,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.insightsCardNoData,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            : OverlayedFoodFingerprint(
                layers: layers,
                axisLabels: axisLabels,
                size: size,
              ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPreview extends ConsumerWidget {
  const _TrendPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wellnessDailySeriesProvider);
    return async.maybeWhen(
      data: (series) {
        if (series.length < 2) return const _PreviewEmpty();
        final tail = series.length > 30
            ? series.sublist(series.length - 30)
            : series;
        return WellnessSparkline(
          points: [for (final p in tail) (t: p.day, score: p.score)],
          height: 48,
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
    final filter = ref.watch(insightsCalendarRangeProvider);
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
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _CalendarRangeToggle(includeYear: true),
            ),
            Expanded(
              child: switch (filter) {
                TimeFilter.day => _DayView(scores: scores),
                TimeFilter.week => _WeekView(scores: scores),
                TimeFilter.month => _MonthView(scores: scores),
                TimeFilter.year => _YearView(scores: scores),
              },
            ),
          ],
        );
      },
    );
  }
}

/// Compact day/week/month toggle that lives inside the calendar card. Year
/// is omitted — the strip becomes too dense on mobile.
class _CalendarRangeToggle extends ConsumerWidget {
  final bool includeYear;
  const _CalendarRangeToggle({this.includeYear = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(insightsCalendarRangeProvider);
    final options = [
      TimeFilter.day,
      TimeFilter.week,
      TimeFilter.month,
      if (includeYear) TimeFilter.year,
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: SegmentedButton<TimeFilter>(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.labelSmall,
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: [
          for (final o in options)
            ButtonSegment(
              value: o,
              label: Text(
                switch (o) {
                  TimeFilter.day => l10n.timeFilterDay,
                  TimeFilter.week => l10n.timeFilterWeek,
                  TimeFilter.month => l10n.timeFilterMonth,
                  TimeFilter.year => l10n.timeFilterYear,
                },
              ),
            ),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (s) =>
            ref.read(insightsCalendarRangeProvider.notifier).state = s.first,
      ),
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
      children: [
        for (final m in months)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: CalendarHeatmap(dailyScores: scores, month: m),
          ),
      ],
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
    final stress = ref.watch(stressImpactProvider);

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
        // Header block = timing card + optional stress card, in that order.
        final header = <Widget>[];
        timing.maybeWhen(
          data: (analysis) {
            if (analysis.buckets.isNotEmpty) {
              header.add(TimingAnalysisCard(analysis: analysis));
            }
          },
          orElse: () {},
        );
        stress.maybeWhen(
          data: (s) {
            if (s != null) header.add(StressImpactCard(impact: s));
          },
          orElse: () {},
        );

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: header.length + items.length,
          itemBuilder: (ctx, i) {
            if (i < header.length) {
              return StaggeredEntrance(
                index: i,
                baseDelay: const Duration(milliseconds: 30),
                child: header[i],
              );
            }
            return StaggeredEntrance(
              index: i,
              baseDelay: const Duration(milliseconds: 30),
              child: FoodImpactCard(score: items[i - header.length]),
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
                FoodFingerprint(
                  foodName: name,
                  data: fp,
                  size: 260,
                  axisLabels: [
                    l10n.insightsMetricGutPeace,
                    l10n.insightsMetricBloating,
                    l10n.insightsMetricHeartburn,
                    l10n.insightsMetricDiarrhea,
                  ],
                ),
              ],
            ),
          );
        }

        // Default view: overlay the 3 worst + 3 best foods so the user sees
        // the extremes of their log at a glance. Single foods can still be
        // tapped below to drill into their individual radar.
        final extremes = selectBestAndWorstFingerprints(fingerprints, topN: 3);
        final axisLabels = [
          l10n.insightsMetricGutPeace,
          l10n.insightsMetricBloating,
          l10n.insightsMetricHeartburn,
          l10n.insightsMetricDiarrhea,
        ];

        // Monochromatic shades so the reader can tell at a glance which group
        // a food belongs to. Rank 1 (most extreme) is the darkest; rank 3 is
        // the lightest. Worst = red family, best = green family.
        ({List<FingerprintLayer> worst, List<FingerprintLayer> best})
            buildGroupedLayers() {
          const worstShades = [
            Color(0xFFB71C1C), // worst (rank 1, darkest red)
            Color(0xFFE53935), // rank 2
            Color(0xFFEF9A9A), // rank 3 (lightest red)
          ];
          const bestShades = [
            Color(0xFF1B5E20), // best (rank 1, darkest green)
            Color(0xFF43A047), // rank 2
            Color(0xFFA5D6A7), // rank 3 (lightest green)
          ];
          List<FingerprintLayer> layersFrom(
            List<MapEntry<int, FoodFingerprintData>> src,
            List<Color> palette,
          ) {
            return [
              for (int i = 0; i < src.length; i++)
                FingerprintLayer(
                  name: _resolveIngredientName(
                    ref,
                    src[i].key,
                    src[i].value.fallbackName,
                    locale,
                  ),
                  data: src[i].value,
                  color: palette[i.clamp(0, palette.length - 1)],
                ),
            ];
          }

          return (
            worst: layersFrom(extremes.worst, worstShades),
            best: layersFrom(extremes.best, bestShades),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length + 1, // +1 header overlay card
          itemBuilder: (ctx, i) {
            if (i == 0) {
              final grouped = buildGroupedLayers();
              if (grouped.worst.isEmpty && grouped.best.isEmpty) {
                return const SizedBox.shrink();
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.insightsFingerprintOverlayTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.insightsFingerprintOverlaySubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          // On narrow screens stack the two radars vertically;
                          // on wider screens show them side-by-side.
                          final wide = constraints.maxWidth > 520;
                          final radarSize = wide
                              ? ((constraints.maxWidth - 24) / 2).clamp(200.0, 260.0)
                              : constraints.maxWidth.clamp(200.0, 300.0);
                          final worst = _GroupedRadar(
                            title: l10n.insightsFingerprintWorst,
                            accent: const Color(0xFFE53935),
                            layers: grouped.worst,
                            axisLabels: axisLabels,
                            size: radarSize.toDouble(),
                          );
                          final best = _GroupedRadar(
                            title: l10n.insightsFingerprintBest,
                            accent: const Color(0xFF43A047),
                            layers: grouped.best,
                            axisLabels: axisLabels,
                            size: radarSize.toDouble(),
                          );
                          if (wide) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: worst),
                                const SizedBox(width: 16),
                                Expanded(child: best),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              worst,
                              const SizedBox(height: 20),
                              best,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            final listIdx = i - 1;
            final entry = sorted[listIdx];
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
              index: listIdx,
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
                    'Bloating ${fp.bloating.toStringAsFixed(1)} · '
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

/// Scatter view: a vertical stack of scatter plots, one per food. Default
/// shows the top 10 by |correlation|; a "Show more" chip at the bottom
/// expands to the full list.
class InsightsScatterView extends ConsumerStatefulWidget {
  const InsightsScatterView({super.key});

  @override
  ConsumerState<InsightsScatterView> createState() =>
      _InsightsScatterViewState();
}

class _InsightsScatterViewState extends ConsumerState<InsightsScatterView> {
  bool _showAll = false;
  static const _topN = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scores = ref.watch(foodImpactScoresProvider);
    final heatmap = ref.watch(heatmapDataProvider);
    final mealTimesAll = ref.watch(mealTimesByIngredientProvider);

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
        return heatmap.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.genericError(e))),
          data: (dailyScores) => mealTimesAll.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.genericError(e))),
            data: (mealTimesMap) {
              final median = dailyScores.isEmpty
                  ? 50.0
                  : dailyScores.values.reduce((a, b) => a + b) /
                      dailyScores.length;
              final visible =
                  _showAll ? items : items.take(_topN).toList();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: visible.length + 1, // trailing toggle/footer
                itemBuilder: (ctx, i) {
                  if (i == visible.length) {
                    if (items.length <= _topN) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          l10n.insightsScatterShowingAll(items.length),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _showAll = !_showAll),
                          icon: Icon(
                            _showAll
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                          ),
                          label: Text(
                            _showAll
                                ? l10n.insightsScatterShowLess
                                : l10n.insightsScatterShowMore(
                                    items.length - _topN,
                                  ),
                          ),
                        ),
                      ),
                    );
                  }

                  final s = visible[i];
                  final times = mealTimesMap[s.ingredientId] ?? const [];
                  final spots = CorrelationScatterPlot.buildSpots(
                    mealTimes: times,
                    dailyScores: dailyScores,
                    color: s.isHarmful ? Colors.red : Colors.green,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: LocalizedIngredientText(
                                    ingredientId: s.ingredientId,
                                    fallbackName: s.ingredientName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (s.isSignificant)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      l10n.insightsScatterSignificant,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _localizedImpactSummary(s, l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 180,
                              child: CorrelationScatterPlot(
                                ingredientId: s.ingredientId,
                                ingredientName: s.ingredientName,
                                spots: spots,
                                medianScore: median,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
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

/// Compact dropdown pill that replaces the wide segmented button. Shows the
/// current metric as "Symptom: [name]" and opens a menu on tap. Scales to
/// any number of symptoms without running off-screen.
class InsightsMetricToggleBar extends ConsumerWidget {
  const InsightsMetricToggleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(insightsMetricProvider);
    final theme = Theme.of(context);

    String labelFor(WellnessMetric m) => switch (m) {
          WellnessMetric.gutPeace => l10n.insightsMetricGutPeace,
          WellnessMetric.bloating => l10n.insightsMetricBloating,
          WellnessMetric.heartburn => l10n.insightsMetricHeartburn,
          WellnessMetric.diarrhea => l10n.insightsMetricDiarrhea,
          WellnessMetric.combined => l10n.insightsMetricCombined,
        };
    IconData iconFor(WellnessMetric m) => switch (m) {
          WellnessMetric.gutPeace => Icons.sentiment_satisfied_rounded,
          WellnessMetric.bloating => Icons.bubble_chart_rounded,
          WellnessMetric.heartburn => Icons.local_fire_department_rounded,
          WellnessMetric.diarrhea => Icons.water_drop_rounded,
          WellnessMetric.combined => Icons.analytics_rounded,
        };

    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<WellnessMetric>(
        initialValue: selected,
        onSelected: (m) =>
            ref.read(insightsMetricProvider.notifier).state = m,
        itemBuilder: (ctx) => [
          for (final m in WellnessMetric.values)
            PopupMenuItem(
              value: m,
              child: Row(
                children: [
                  Icon(
                    iconFor(m),
                    size: 18,
                    color: m == selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Text(labelFor(m)),
                ],
              ),
            ),
        ],
        tooltip: l10n.insightsMetricTooltip,
        position: PopupMenuPosition.under,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconFor(selected), size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${l10n.insightsMetricPrefix}: ${labelFor(selected)}',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
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
