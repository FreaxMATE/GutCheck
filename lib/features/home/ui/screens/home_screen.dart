import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../insights/domain/impact_score.dart';
import '../../../meal_log/data/models/meal_entry.dart';
import '../../../wellness/data/models/wellness_entry.dart';
import '../../../wellness/ui/widgets/wellness_score_ring.dart';
import '../../providers/home_providers.dart';
import '../widgets/greeting_banner.dart';
import '../widgets/weekly_digest_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, MMMM d').format(DateTime.now())),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(lastWellnessProvider);
          ref.invalidate(lastMealProvider);
          ref.invalidate(weeklyWellnessAvgProvider);
          ref.invalidate(dashboardTopImpactProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          children: [
            const StaggeredEntrance(index: 0, child: GreetingBanner()),
            const SizedBox(height: 8),
            const StaggeredEntrance(index: 1, child: WeeklyDigestCard()),
            const SizedBox(height: 8),
            StaggeredEntrance(index: 1, child: _LastWellnessCard(l10n: l10n)),
            const SizedBox(height: 12),
            StaggeredEntrance(index: 2, child: _LastMealCard(l10n: l10n)),
            const SizedBox(height: 12),
            StaggeredEntrance(index: 3, child: _WeeklyTrendCard(l10n: l10n)),
            const SizedBox(height: 12),
            StaggeredEntrance(index: 4, child: _TopInsightCard(l10n: l10n)),
          ],
        ),
      ),
    );
  }
}

// ── Last Wellness Card ────────────────────────────────────────────────────────

class _LastWellnessCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _LastWellnessCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(lastWellnessProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: l10n.homeLastWellnessTitle),
            const SizedBox(height: 12),
            AnimatedAsyncSwitcher(
              child: async.when(
                loading: () => const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator()),
                error: (e, _) => Text(l10n.genericError(e),
                    key: const ValueKey('error')),
                data: (entry) => entry == null
                    ? _EmptyCardContent(
                        key: const ValueKey('empty'),
                        message: l10n.homeNoWellnessYet)
                    : _WellnessContent(
                        key: ValueKey('wellness-${entry.id}'),
                        entry: entry,
                        l10n: l10n),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.push('/wellness/history'),
                  child: Text(l10n.homeViewHistory),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => context.go('/wellness'),
                  child: Text(l10n.homeLogWellness),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessContent extends StatelessWidget {
  final WellnessEntry entry;
  final AppLocalizations l10n;
  const _WellnessContent({super.key, required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heartburnColor = Color.lerp(
        Colors.green, Colors.red, (entry.heartburn - 1) / 9.0)!;
    final gutColor = Color.lerp(
        Colors.red, Colors.green, (entry.gutPeace - 1) / 9.0)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GutDateUtils.timeAgoLocalized(entry.recordedAt, l10n),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite_rounded, size: 16, color: gutColor),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.wellnessGutPeace}: ${entry.gutPeace}/10',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 16, color: heartburnColor),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.wellnessHeartburn}: ${entry.heartburn}/10',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (entry.diarrhea) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.water_drop_rounded,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      l10n.wellnessDiarrhea,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.orange),
                    ),
                  ],
                ),
              ],
              if (entry.notes != null) ...[
                const SizedBox(height: 6),
                Text(
                  entry.notes!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        WellnessScoreRing(discomfort: entry.gutPeace, size: 80),
      ],
    );
  }
}

// ── Last Meal Card ────────────────────────────────────────────────────────────

class _LastMealCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _LastMealCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(lastMealProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: l10n.homeLastMealTitle),
            const SizedBox(height: 12),
            AnimatedAsyncSwitcher(
              child: async.when(
                loading: () => const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator()),
                error: (e, _) => Text(l10n.genericError(e),
                    key: const ValueKey('error')),
                data: (meal) => meal == null
                    ? _EmptyCardContent(
                        key: const ValueKey('empty'),
                        message: l10n.homeNoMealsYet)
                    : _MealContent(
                        key: ValueKey('meal-${meal.id}'),
                        meal: meal,
                        l10n: l10n),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.go('/log'),
                  child: Text(l10n.homeViewLog),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => context.go('/log'),
                  child: Text(l10n.homeLogMeal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MealContent extends StatelessWidget {
  final MealEntry meal;
  final AppLocalizations l10n;
  const _MealContent({super.key, required this.meal, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = localizedMealLabel(meal.mealLabel, l10n);
    final chips = meal.ingredients.take(5).toList();
    final overflow = meal.ingredients.length - 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(
              GutDateUtils.timeAgoLocalized(meal.consumedAt, l10n),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            ...chips.map((i) => Chip(
                  label: Text(i.ingredientName,
                      style: theme.textTheme.labelSmall),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )),
            if (overflow > 0)
              Chip(
                label: Text('+$overflow',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.grey)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}

// ── Weekly Trend Card ─────────────────────────────────────────────────────────

class _WeeklyTrendCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _WeeklyTrendCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weeklyWellnessAvgProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (avg) {
        if (avg == null) return const SizedBox.shrink();
        final color = AppColors.wellnessScoreInterpolated(avg);
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: l10n.homeWeeklyAvgTitle),
                      const SizedBox(height: 4),
                      Text(
                        _weekDescription(avg, l10n),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    avg.round().toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _weekDescription(double avg, AppLocalizations l10n) {
    if (avg >= 70) return l10n.wellnessScoreGreat;
    if (avg >= 50) return l10n.wellnessScoreOkay;
    if (avg >= 35) return l10n.wellnessSomeDiscomfort;
    return l10n.wellnessSignificantSymptoms;
  }
}

// ── Top Insight Card ──────────────────────────────────────────────────────────

class _TopInsightCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _TopInsightCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardTopImpactProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (impact) {
        final harmful = impact.harmful;
        final beneficial = impact.beneficial;

        if (harmful == null && beneficial == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: l10n.homeTopInsightTitle),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeNoInsightYet,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _SectionLabel(label: l10n.homeTopInsightTitle)),
                    TextButton(
                      onPressed: () => context.go('/insights'),
                      child: Text(l10n.homeViewInsights),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (harmful != null)
                  _InsightRow(
                    score: harmful,
                    isHarmful: true,
                    label: l10n.homePossibleTrigger,
                    l10n: l10n,
                  ),
                if (harmful != null && beneficial != null)
                  const SizedBox(height: 8),
                if (beneficial != null)
                  _InsightRow(
                    score: beneficial,
                    isHarmful: false,
                    label: l10n.homeLikelyBeneficial,
                    l10n: l10n,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InsightRow extends StatelessWidget {
  final ImpactScore score;
  final bool isHarmful;
  final String label;
  final AppLocalizations l10n;

  const _InsightRow({
    required this.score,
    required this.isHarmful,
    required this.label,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isHarmful ? Colors.red : Colors.green;
    final icon = isHarmful ? Icons.warning_amber_rounded : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.ingredientName,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$label · ${score.correlationPercent}% '
                  '${isHarmful ? l10n.impactDrop : l10n.impactImprovement} '
                  '(${score.bestZone.shortLabel})',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _EmptyCardContent extends StatelessWidget {
  final String message;
  const _EmptyCardContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Colors.grey),
    );
  }
}
