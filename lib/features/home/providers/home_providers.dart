import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../../insights/domain/correlation_engine.dart';
import '../../insights/domain/impact_score.dart';
import '../../meal_log/data/models/meal_entry.dart';
import '../../wellness/data/models/wellness_entry.dart';

/// The most recent wellness entry in the last 30 days.
final lastWellnessProvider = FutureProvider.autoDispose<WellnessEntry?>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day - 30);
  final to = DateTime(now.year, now.month, now.day + 1);
  final entries = await db.wellnessInRange(from: from, to: to);
  return entries.isEmpty ? null : entries.last;
});

/// The most recent meal entry in the last 30 days.
final lastMealProvider = FutureProvider.autoDispose<MealEntry?>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day - 30);
  final to = DateTime(now.year, now.month, now.day + 1);
  final entries = await db.mealsInRange(from: from, to: to);
  return entries.isEmpty ? null : entries.last;
});

/// Average wellness score over the last 7 days, or null if no data.
final weeklyWellnessAvgProvider = FutureProvider.autoDispose<double?>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day - 7);
  final to = DateTime(now.year, now.month, now.day + 1);
  final entries = await db.wellnessInRange(from: from, to: to);
  if (entries.isEmpty) return null;
  return entries.fold<double>(0, (sum, e) => sum + e.wellnessScore) /
      entries.length;
});

typedef DashboardTopImpact = ({ImpactScore? harmful, ImpactScore? beneficial});

/// Top harmful and top beneficial food correlations over the last 30 days.
final dashboardTopImpactProvider =
    FutureProvider.autoDispose<DashboardTopImpact>((ref) async {
      final db = await ref.watch(appDatabaseProvider.future);
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day - 30);
      final to = DateTime(now.year, now.month, now.day + 1);

      final meals = await db.mealsInRange(from: from, to: to);
      final wellness = await db.wellnessInRange(from: from, to: to);

      if (meals.isEmpty || wellness.isEmpty) {
        return (harmful: null, beneficial: null);
      }

      final scores = CorrelationEngine.computeImpactScores(
        meals: meals,
        wellnessEntries: wellness,
      );

      ImpactScore? harmful;
      ImpactScore? beneficial;
      for (final s in scores) {
        if (s.sampleCount < 3) continue;
        if (s.isHarmful &&
            (harmful == null || s.rankScore > harmful.rankScore)) {
          harmful = s;
        }
        if (!s.isHarmful &&
            (beneficial == null || s.rankScore > beneficial.rankScore)) {
          beneficial = s;
        }
      }
      return (harmful: harmful, beneficial: beneficial);
    });
