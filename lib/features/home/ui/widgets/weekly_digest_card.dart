import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../wellness/domain/wellness_display.dart';

/// A "your week" summary card showing the trailing 7 days at a glance.
/// Counts up numbers from zero on appearance.
class WeeklyDigestCard extends ConsumerWidget {
  const WeeklyDigestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<_DigestData>(
      future: _loadData(ref),
      builder: (ctx, snap) {
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        if (data.mealCount == 0 && data.wellnessCount == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.weeklyDigestTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CountTile(
                        value: data.mealCount,
                        label: l10n.weeklyDigestMeals,
                        color: Colors.orange,
                        icon: Icons.restaurant_rounded,
                      ),
                    ),
                    Expanded(
                      child: _CountTile(
                        value: data.wellnessCount,
                        label: l10n.weeklyDigestWellness,
                        color: Colors.redAccent,
                        icon: Icons.favorite_rounded,
                      ),
                    ),
                    Expanded(
                      child: _VarietyTile(
                        uniqueFoodCount: data.uniqueFoodCount,
                        avgWellness: data.avgWellness,
                        l10n: l10n,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_DigestData> _loadData(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 7);
    final end = DateTime(now.year, now.month, now.day + 1);
    final meals = await db.mealsInRange(from: start, to: end);
    final wellness = await db.wellnessInRange(from: start, to: end);
    final avg = wellness.isEmpty
        ? null
        : wellness.fold<double>(0, (a, w) => a + w.wellnessScore) /
              wellness.length;

    final uniqueFoodIds = <int>{};
    for (final m in meals) {
      for (final i in m.ingredients) {
        uniqueFoodIds.add(i.ingredientId);
      }
    }

    return _DigestData(
      mealCount: meals.length,
      wellnessCount: wellness.length,
      avgWellness: avg,
      uniqueFoodCount: uniqueFoodIds.length,
    );
  }
}

class _DigestData {
  final int mealCount;
  final int wellnessCount;
  final double? avgWellness;
  final int uniqueFoodCount;
  _DigestData({
    required this.mealCount,
    required this.wellnessCount,
    required this.uniqueFoodCount,
    this.avgWellness,
  });
}

/// Third tile: a "food variety" counter. Celebrates dietary breadth without
/// gamifying adherence. More varied weeks generally produce better-quality
/// correlation data — so the number is both a flex and an actionable nudge.
class _VarietyTile extends ConsumerWidget {
  final int uniqueFoodCount;
  final double? avgWellness;
  final AppLocalizations l10n;

  const _VarietyTile({
    required this.uniqueFoodCount,
    required this.avgWellness,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationsOn = ref.watch(animationsEnabledProvider);
    final accent = _colorForVariety(uniqueFoodCount);
    return Column(
      children: [
        Icon(Icons.spa_rounded, color: accent, size: 20),
        const SizedBox(height: 4),
        animationsOn
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: uniqueFoodCount.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text(
                  v.round().toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              )
            : Text(
                uniqueFoodCount.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
        Text(
          l10n.weeklyDigestVariety,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        if (avgWellness != null) ...[
          const SizedBox(height: 4),
          Text(
            'Ø ${WellnessDisplay.format(avgWellness!)}${WellnessDisplay.suffix}',
            style: TextStyle(
              fontSize: 10,
              color: avgWellness != null
                  ? AppColors.wellnessScoreInterpolated(avgWellness!)
                  : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Muted green spectrum: richer greens for more variety, fading to grey.
  static Color _colorForVariety(int n) {
    if (n >= 25) return const Color(0xFF2E7D32);
    if (n >= 15) return const Color(0xFF43A047);
    if (n >= 8) return const Color(0xFF66BB6A);
    if (n >= 3) return const Color(0xFF9CCC65);
    return Colors.grey;
  }
}

class _CountTile extends ConsumerWidget {
  final int value;
  final String label;
  final Color color;
  final IconData icon;
  const _CountTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationsOn = ref.watch(animationsEnabledProvider);
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        animationsOn
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text(
                  v.round().toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              )
            : Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
