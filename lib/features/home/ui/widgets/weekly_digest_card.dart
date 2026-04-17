import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../wellness/domain/wellness_display.dart';

/// A "your week" summary card. Appears only on Sunday / Monday to review
/// the prior 7 days. Counts up numbers from zero on appearance.
class WeeklyDigestCard extends ConsumerWidget {
  const WeeklyDigestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    // Only show on Sunday (7) and Monday (1). Otherwise render nothing.
    if (now.weekday != DateTime.sunday && now.weekday != DateTime.monday) {
      return const SizedBox.shrink();
    }
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
                        color: Colors.red,
                        icon: Icons.favorite_rounded,
                      ),
                    ),
                    Expanded(
                      child: _CountTile(
                        value: data.streak,
                        label: l10n.weeklyDigestStreak,
                        color: Colors.deepOrange,
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                  ],
                ),
                if (data.avgWellness != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.weeklyDigestAvgScore(
                      '${WellnessDisplay.format(data.avgWellness!)}${WellnessDisplay.suffix}',
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
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

    // Compute streak (consecutive days with any log).
    final days = <DateTime>{
      for (final m in meals)
        DateTime(m.consumedAt.year, m.consumedAt.month, m.consumedAt.day),
      for (final w in wellness)
        DateTime(w.recordedAt.year, w.recordedAt.month, w.recordedAt.day),
    };
    int streak = 0;
    for (int i = 0; i < 60; i++) {
      final d = DateTime(now.year, now.month, now.day - i);
      if (days.contains(d)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return _DigestData(
      mealCount: meals.length,
      wellnessCount: wellness.length,
      avgWellness: avg,
      streak: streak,
    );
  }
}

class _DigestData {
  final int mealCount;
  final int wellnessCount;
  final double? avgWellness;
  final int streak;
  _DigestData({
    required this.mealCount,
    required this.wellnessCount,
    required this.streak,
    this.avgWellness,
  });
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
