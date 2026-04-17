import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../data/repositories/insights_repository.dart';
import '../domain/correlation_engine.dart';
import '../domain/impact_score.dart';
import '../domain/timing_analysis.dart';
import '../ui/widgets/food_fingerprint.dart';

enum WellnessMetric { gutPeace, heartburn, diarrhea, stress, combined }

final insightsMetricProvider = StateProvider<WellnessMetric>(
  (ref) => WellnessMetric.gutPeace,
);

final insightsTimeFilterProvider = StateProvider<TimeFilter>(
  (ref) => TimeFilter.week,
);

/// Daily aggregated scores. Respects both the time filter and the metric
/// toggle, so the calendar, scatter plot, and other views stay in sync.
final heatmapDataProvider = FutureProvider.autoDispose<Map<DateTime, double>>((
  ref,
) async {
  final filter = ref.watch(insightsTimeFilterProvider);
  final metric = ref.watch(insightsMetricProvider);
  final range = filter.toDateRange();
  final db = await ref.watch(appDatabaseProvider.future);
  final entries = await db.wellnessInRange(from: range.start, to: range.end);

  final extractor = switch (metric) {
    WellnessMetric.heartburn => CorrelationEngine.heartburnAsY,
    WellnessMetric.diarrhea => CorrelationEngine.diarrheaAsY,
    WellnessMetric.stress => CorrelationEngine.stressAsY,
    WellnessMetric.combined => CorrelationEngine.combinedAsY,
    WellnessMetric.gutPeace => null,
  };

  return InsightsRepository.aggregateByDay(entries, scoreExtractor: extractor);
});

final foodImpactScoresProvider = FutureProvider.autoDispose<List<ImpactScore>>((
  ref,
) async {
  final filter = ref.watch(insightsTimeFilterProvider);
  final metric = ref.watch(insightsMetricProvider);
  final range = filter.toDateRange();
  final db = await ref.watch(appDatabaseProvider.future);

  final meals = await db.mealsInRange(from: range.start, to: range.end);
  final wellness = await db.wellnessInRange(from: range.start, to: range.end);

  final extractor = switch (metric) {
    WellnessMetric.heartburn => CorrelationEngine.heartburnAsY,
    WellnessMetric.diarrhea => CorrelationEngine.diarrheaAsY,
    WellnessMetric.stress => CorrelationEngine.stressAsY,
    WellnessMetric.combined => CorrelationEngine.combinedAsY,
    WellnessMetric.gutPeace => null,
  };

  return CorrelationEngine.computeImpactScores(
    meals: meals,
    wellnessEntries: wellness,
    yValueExtractor: extractor,
  );
});

final selectedImpactScoreProvider = StateProvider<ImpactScore?>((ref) => null);

/// Meal timestamps for the currently selected ingredient, used by the scatter
/// plot to build [ScatterSpot] objects.
final selectedIngredientMealTimesProvider =
    FutureProvider.autoDispose<List<DateTime>>((ref) async {
      final selected = ref.watch(selectedImpactScoreProvider);
      if (selected == null) return [];

      final filter = ref.watch(insightsTimeFilterProvider);
      final range = filter.toDateRange();
      final db = await ref.watch(appDatabaseProvider.future);
      final meals = await db.mealsInRange(from: range.start, to: range.end);

      return meals
          .where(
            (m) => m.ingredients.any(
              (i) => i.ingredientId == selected.ingredientId,
            ),
          )
          .map((m) => m.consumedAt)
          .toList();
    });

/// Meal-timing analysis: how WHEN the user eats affects discomfort.
final timingAnalysisProvider = FutureProvider.autoDispose<TimingAnalysis>((
  ref,
) async {
  final filter = ref.watch(insightsTimeFilterProvider);
  final range = filter.toDateRange();
  final db = await ref.watch(appDatabaseProvider.future);
  final meals = await db.mealsInRange(from: range.start, to: range.end);
  final wellness = await db.wellnessInRange(from: range.start, to: range.end);
  return TimingAnalyzer.analyze(meals: meals, wellness: wellness);
});

/// Food fingerprint data for each ingredient with enough data.
final foodFingerprintProvider =
    FutureProvider.autoDispose<Map<int, FoodFingerprintData>>((ref) async {
      final filter = ref.watch(insightsTimeFilterProvider);
      final range = filter.toDateRange();
      final db = await ref.watch(appDatabaseProvider.future);
      final meals = await db.mealsInRange(from: range.start, to: range.end);
      final wellness = await db.wellnessInRange(
        from: range.start,
        to: range.end,
      );
      return computeFingerprints(meals: meals, wellness: wellness);
    });

/// Currently selected food for the fingerprint detail view.
final selectedFingerprintFoodProvider = StateProvider<int?>((ref) => null);
