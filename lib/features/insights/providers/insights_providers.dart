import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../wellness/data/models/wellness_entry.dart';
import '../data/repositories/insights_repository.dart';
import '../domain/correlation_engine.dart';
import '../domain/impact_score.dart';
import '../domain/timing_analysis.dart';
import '../ui/widgets/food_fingerprint.dart';

enum WellnessMetric { gutPeace, bloating, heartburn, diarrhea, combined }

final insightsMetricProvider = StateProvider<WellnessMetric>(
  (ref) => WellnessMetric.gutPeace,
);

/// View-range for the calendar card. Correlation-based analyses ignore this —
/// they always use the user's full history. This only changes how much of the
/// calendar strip is rendered at once.
final insightsCalendarRangeProvider = StateProvider<TimeFilter>(
  (ref) => TimeFilter.week,
);

double Function(WellnessEntry)? _extractorFor(WellnessMetric metric) {
  return switch (metric) {
    WellnessMetric.heartburn => CorrelationEngine.heartburnAsY,
    WellnessMetric.bloating => CorrelationEngine.bloatingAsY,
    WellnessMetric.diarrhea => CorrelationEngine.diarrheaAsY,
    WellnessMetric.combined => CorrelationEngine.combinedAsY,
    WellnessMetric.gutPeace => null,
  };
}

/// Stress-as-predictor correlation against the currently selected symptom
/// metric, over the full wellness history.
final stressImpactProvider = FutureProvider.autoDispose<StressImpact?>((
  ref,
) async {
  final metric = ref.watch(insightsMetricProvider);
  final db = await ref.watch(appDatabaseProvider.future);
  final wellness = await db.allWellness();
  return CorrelationEngine.computeStressImpact(
    wellnessEntries: wellness,
    yValueExtractor: _extractorFor(metric),
  );
});

/// Daily aggregated scores over the user's FULL history. The UI layer decides
/// how much of this to render (e.g. last week vs last month) — the provider
/// always returns everything so zooming is instant and cache-friendly.
final heatmapDataProvider = FutureProvider.autoDispose<Map<DateTime, double>>((
  ref,
) async {
  final metric = ref.watch(insightsMetricProvider);
  final db = await ref.watch(appDatabaseProvider.future);
  final entries = await db.allWellness();
  return InsightsRepository.aggregateByDay(
    entries,
    scoreExtractor: _extractorFor(metric),
  );
});

final foodImpactScoresProvider = FutureProvider.autoDispose<List<ImpactScore>>((
  ref,
) async {
  final metric = ref.watch(insightsMetricProvider);
  final db = await ref.watch(appDatabaseProvider.future);
  final meals = await db.allMeals();
  final wellness = await db.allWellness();
  return CorrelationEngine.computeImpactScores(
    meals: meals,
    wellnessEntries: wellness,
    yValueExtractor: _extractorFor(metric),
  );
});

final selectedImpactScoreProvider = StateProvider<ImpactScore?>((ref) => null);

/// Meal timestamps for the currently selected ingredient, used by the scatter
/// plot to build [ScatterSpot] objects.
final selectedIngredientMealTimesProvider =
    FutureProvider.autoDispose<List<DateTime>>((ref) async {
      final selected = ref.watch(selectedImpactScoreProvider);
      if (selected == null) return [];

      final db = await ref.watch(appDatabaseProvider.future);
      final meals = await db.allMeals();

      return meals
          .where(
            (m) => m.ingredients.any(
              (i) => i.ingredientId == selected.ingredientId,
            ),
          )
          .map((m) => m.consumedAt)
          .toList();
    });

/// Meal timestamps grouped by ingredient id. Used by the scatter screen to
/// render a vertical list of scatter plots, one per food, without round-tripping
/// the DB for each selection.
final mealTimesByIngredientProvider =
    FutureProvider.autoDispose<Map<int, List<DateTime>>>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final meals = await db.allMeals();
  final out = <int, List<DateTime>>{};
  for (final m in meals) {
    for (final i in m.ingredients) {
      out.putIfAbsent(i.ingredientId, () => []).add(m.consumedAt);
    }
  }
  return out;
});

/// Meal-timing analysis: how WHEN the user eats affects discomfort. All-time.
final timingAnalysisProvider = FutureProvider.autoDispose<TimingAnalysis>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final meals = await db.allMeals();
  final wellness = await db.allWellness();
  return TimingAnalyzer.analyze(meals: meals, wellness: wellness);
});

/// Food radar data for each ingredient with enough data. All-time.
final foodFingerprintProvider =
    FutureProvider.autoDispose<Map<int, FoodFingerprintData>>((ref) async {
      final db = await ref.watch(appDatabaseProvider.future);
      final meals = await db.allMeals();
      final wellness = await db.allWellness();
      return computeFingerprints(meals: meals, wellness: wellness);
    });

/// Currently selected food for the radar detail view.
final selectedFingerprintFoodProvider = StateProvider<int?>((ref) => null);

/// Per-day average wellness score across the user's full history, sorted by
/// day ascending. Days with no entry are omitted (the trend line draws straight
/// segments across gaps).
final wellnessDailySeriesProvider =
    FutureProvider.autoDispose<List<({DateTime day, double score})>>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final entries = await db.allWellness();
  final byDay = InsightsRepository.aggregateByDay(entries);
  final keys = byDay.keys.toList()..sort();
  return [for (final k in keys) (day: k, score: byDay[k]!)];
});

/// Every wellness entry across the user's full history (one point per logged
/// check-in), sorted by recordedAt ascending. Used by the trend view at low
/// data density; aggregation kicks in once the count exceeds the threshold.
final wellnessEntrySeriesProvider =
    FutureProvider.autoDispose<List<({DateTime t, double score})>>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final entries = await db.allWellness();
  entries.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  return [
    for (final e in entries) (t: e.recordedAt, score: e.wellnessScore),
  ];
});
