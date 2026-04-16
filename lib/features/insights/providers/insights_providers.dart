import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../data/repositories/insights_repository.dart';
import '../domain/correlation_engine.dart';
import '../domain/impact_score.dart';
import '../domain/timing_analysis.dart';

enum WellnessMetric { gutPeace, heartburn, diarrhea, combined }

final insightsMetricProvider =
    StateProvider<WellnessMetric>((ref) => WellnessMetric.gutPeace);

final insightsTimeFilterProvider =
    StateProvider<TimeFilter>((ref) => TimeFilter.week);

/// Daily aggregated scores for the last 3 months, used by the calendar
/// heatmap and the scatter plot's median line. Intentionally independent of
/// [insightsTimeFilterProvider] so the calendar always shows a consistent
/// 3-month view.
final heatmapDataProvider =
    FutureProvider.autoDispose<Map<DateTime, double>>((ref) async {
  final metric = ref.watch(insightsMetricProvider);
  final db = await ref.watch(appDatabaseProvider.future);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 3, 1);
  final to = DateTime(now.year, now.month, now.day + 1);
  final entries = await db.wellnessInRange(from: from, to: to);

  // Each extractor returns a "higher = better" 0-100 score so the calendar's
  // green=good / red=bad color logic stays consistent across metrics.
  final extractor = switch (metric) {
    WellnessMetric.heartburn => CorrelationEngine.heartburnAsY,
    WellnessMetric.diarrhea => CorrelationEngine.diarrheaAsY,
    WellnessMetric.combined => CorrelationEngine.combinedAsY,
    WellnessMetric.gutPeace => null, // falls back to wellnessScore
  };

  return InsightsRepository.aggregateByDay(entries,
      scoreExtractor: extractor);
});

final foodImpactScoresProvider =
    FutureProvider.autoDispose<List<ImpactScore>>((ref) async {
  final filter = ref.watch(insightsTimeFilterProvider);
  final metric = ref.watch(insightsMetricProvider);
  final range = filter.toDateRange();
  final db = await ref.watch(appDatabaseProvider.future);

  final meals = await db.mealsInRange(from: range.start, to: range.end);
  final wellness = await db.wellnessInRange(from: range.start, to: range.end);

  final extractor = switch (metric) {
    WellnessMetric.heartburn => CorrelationEngine.heartburnAsY,
    WellnessMetric.diarrhea  => CorrelationEngine.diarrheaAsY,
    WellnessMetric.combined  => CorrelationEngine.combinedAsY,
    WellnessMetric.gutPeace  => null,
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
      .where((m) =>
          m.ingredients.any((i) => i.ingredientId == selected.ingredientId))
      .map((m) => m.consumedAt)
      .toList();
});

/// Meal-timing analysis: how WHEN the user eats affects discomfort.
final timingAnalysisProvider =
    FutureProvider.autoDispose<TimingAnalysis>((ref) async {
  final filter = ref.watch(insightsTimeFilterProvider);
  final range = filter.toDateRange();
  final db = await ref.watch(appDatabaseProvider.future);
  final meals = await db.mealsInRange(from: range.start, to: range.end);
  final wellness = await db.wellnessInRange(from: range.start, to: range.end);
  return TimingAnalyzer.analyze(meals: meals, wellness: wellness);
});
