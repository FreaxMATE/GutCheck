import 'dart:math';

import '../../../core/constants/food_categories.dart';
import '../../meal_log/data/models/meal_entry.dart';
import '../../wellness/data/models/wellness_entry.dart';
import 'impact_score.dart';

class CorrelationEngine {
  CorrelationEngine._();

  // ── Time zones ─────────────────────────────────────────────────────────────

  /// Named time windows for food–wellness correlation.
  /// [from]/[to] are hours after meal time (inclusive start, exclusive end).
  static const timeZones = [
    (from: 0, to: 4, label: 'Immediate', shortLabel: '0–4h'),
    (from: 4, to: 12, label: 'Delayed', shortLabel: '4–12h'),
    (from: 12, to: 24, label: 'Overnight', shortLabel: '12–24h'),
  ];

  // ── Wellness Score ─────────────────────────────────────────────────────────

  /// Compute a 0–100 wellness score from the stored gut discomfort value.
  ///
  /// Values use 2× half-step encoding: stored 0-20 = display 0.0-10.0.
  /// Higher score = better wellness, so we invert.
  static double computeWellnessScore({
    required int gutPeace, // 0–20 (2× encoding)
  }) {
    return ((20 - gutPeace.clamp(0, 20)) / 20.0) * 100.0;
  }

  // ── Impact Scores ──────────────────────────────────────────────────────────

  /// Converts heartburn (stored 0-20, 2× encoding) to a 0–100 "wellness" score.
  /// HIGHER = better (no heartburn).
  static double heartburnAsY(WellnessEntry e) =>
      ((20 - e.heartburn.clamp(0, 20)) / 20.0) * 100.0;

  /// Diarrhea as a 0–100 score: 100 = no diarrhea (good), 0 = diarrhea (bad).
  /// [isHarmful] logic (pearsonR < 0) stays correct: high food → low score → harmful.
  static double diarrheaAsY(WellnessEntry e) => e.diarrhea ? 0.0 : 100.0;

  /// Combined gut health index (0–100) weighting all four inputs:
  ///   40% gut discomfort · 25% heartburn · 15% diarrhea · 20% stress context.
  static double combinedAsY(WellnessEntry e) {
    final gutScore = computeWellnessScore(gutPeace: e.gutPeace);
    final hbScore = heartburnAsY(e);
    final diarrheaScore = e.diarrhea ? 0.0 : 100.0;
    // Stress: 0-20 (2× encoding), invert to wellness: higher stress → lower score.
    final stressScore = ((20 - e.stressLevel.clamp(0, 20)) / 20.0) * 100.0;
    return (0.40 * gutScore +
            0.25 * hbScore +
            0.15 * diarrheaScore +
            0.20 * stressScore)
        .clamp(0.0, 100.0);
  }

  /// Stress level as a wellness-like 0-100 score (higher = less stress = better).
  static double stressAsY(WellnessEntry e) =>
      ((20 - e.stressLevel.clamp(0, 20)) / 20.0) * 100.0;

  /// For each ingredient that appears in [meals], compute a Pearson r
  /// correlation against wellness scores in [wellnessEntries] across the three
  /// named time zones. Returns scores sorted by |r| * confidence.
  static List<ImpactScore> computeImpactScores({
    required List<MealEntry> meals,
    required List<WellnessEntry> wellnessEntries,
    Map<int, String>? ingredientNames,
    Map<int, FoodCategory>? ingredientCategories,
    double Function(WellnessEntry)? yValueExtractor,
  }) {
    if (meals.isEmpty || wellnessEntries.isEmpty) return [];

    final extractY = yValueExtractor ?? (WellnessEntry e) => e.wellnessScore;

    // Build ingredient → list of meal timestamps
    final Map<int, List<DateTime>> ingredientMeals = {};
    final Map<int, String> nameMap = ingredientNames ?? {};
    final Map<int, FoodCategory> categoryMap = ingredientCategories ?? {};

    for (final meal in meals) {
      for (final item in meal.ingredients) {
        ingredientMeals
            .putIfAbsent(item.ingredientId, () => [])
            .add(meal.consumedAt);
        nameMap.putIfAbsent(item.ingredientId, () => item.ingredientName);
      }
    }

    final scores = <ImpactScore>[];

    for (final entry in ingredientMeals.entries) {
      final ingredientId = entry.key;
      final mealTimes = entry.value;
      final name = nameMap[ingredientId] ?? 'Unknown';
      final category = categoryMap[ingredientId] ?? FoodCategory.other;

      double bestR = 0;
      int bestZoneFrom = timeZones.first.from;
      int bestN = 0;
      final pearsonByLag = <int, double>{};

      for (final zone in timeZones) {
        final windowFrom = Duration(hours: zone.from);
        final windowTo = Duration(hours: zone.to);

        final xs = <double>[];
        final ys = <double>[];

        for (final wellness in wellnessEntries) {
          int count = 0;
          for (final mealTime in mealTimes) {
            final start = mealTime.add(windowFrom);
            final end = mealTime.add(windowTo);
            // Wellness recorded within [start, end)
            if (!wellness.recordedAt.isBefore(start) &&
                wellness.recordedAt.isBefore(end)) {
              count++;
            }
          }
          xs.add(count.toDouble());
          ys.add(extractY(wellness));
        }

        if (xs.length < 3) continue;

        final r = _pearson(xs, ys);
        pearsonByLag[zone.from] = r;
        if (r.abs() > bestR.abs()) {
          bestR = r;
          bestZoneFrom = zone.from;
          bestN = xs.where((x) => x > 0).length;
        }
      }

      if (bestN < 3) continue;

      final confidence = (bestN / 20.0).clamp(0.0, 1.0);

      scores.add(
        ImpactScore(
          ingredientId: ingredientId,
          ingredientName: name,
          category: category,
          pearsonR: bestR,
          bestLagHours: bestZoneFrom,
          sampleCount: bestN,
          confidenceLevel: confidence,
          pearsonByLag: pearsonByLag,
        ),
      );
    }

    scores.sort((a, b) => b.rankScore.compareTo(a.rankScore));
    return scores;
  }

  // ── Pearson r ──────────────────────────────────────────────────────────────

  static double _pearson(List<double> x, List<double> y) {
    assert(x.length == y.length && x.isNotEmpty);
    final n = x.length.toDouble();
    final xBar = x.reduce((a, b) => a + b) / n;
    final yBar = y.reduce((a, b) => a + b) / n;

    double num = 0, denX = 0, denY = 0;
    for (int i = 0; i < x.length; i++) {
      final dx = x[i] - xBar;
      final dy = y[i] - yBar;
      num += dx * dy;
      denX += dx * dx;
      denY += dy * dy;
    }

    final denom = sqrt(denX) * sqrt(denY);
    if (denom == 0) return 0.0;
    return (num / denom).clamp(-1.0, 1.0);
  }
}
