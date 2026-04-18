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

  /// Bloating (3-level ordinal, 0=Keine, 1=Leicht, 2=Stark) as a 0–100
  /// "wellness" score. HIGHER = better (no bloating).
  ///   Keine  → 100
  ///   Leicht → 50
  ///   Stark  → 0
  static double bloatingAsY(WellnessEntry e) =>
      ((2 - e.bloating.clamp(0, 2)) / 2.0) * 100.0;

  /// Diarrhea as a 0–100 score: 100 = no diarrhea (good), 0 = diarrhea (bad).
  /// [isHarmful] logic (pearsonR < 0) stays correct: high food → low score → harmful.
  static double diarrheaAsY(WellnessEntry e) => e.diarrhea ? 0.0 : 100.0;

  /// Combined gut health index (0–100) — a weighted average over the four
  /// body-symptom signals only. Stress is NOT included: it is an input/context
  /// variable (like food), not a symptom the user is trying to minimize.
  ///
  /// Bloating is a coarse 3-level ordinal so its weight is reduced vs.
  /// the fine-grained discomfort slider; discomfort picks up the delta.
  ///   45% gut discomfort · 20% bloating · 20% heartburn · 15% diarrhea.
  static double combinedAsY(WellnessEntry e) {
    final gutScore = computeWellnessScore(gutPeace: e.gutPeace);
    final bloatScore = bloatingAsY(e);
    final hbScore = heartburnAsY(e);
    final diarrheaScore = e.diarrhea ? 0.0 : 100.0;
    return (0.45 * gutScore +
            0.20 * bloatScore +
            0.20 * hbScore +
            0.15 * diarrheaScore)
        .clamp(0.0, 100.0);
  }

  /// Correlate self-reported stress against a symptom metric. Stress is
  /// treated like food: an INPUT that may influence downstream symptoms.
  ///
  /// For every wellness entry we pair `x = stressLevel` with `y = metric(e)`.
  /// A negative Spearman r means "higher stress → lower wellness" (what you'd
  /// expect for stress-sensitive symptoms).
  ///
  /// Returns null when the data is insufficient or has zero variance.
  static StressImpact? computeStressImpact({
    required List<WellnessEntry> wellnessEntries,
    double Function(WellnessEntry)? yValueExtractor,
  }) {
    if (wellnessEntries.length < 3) return null;
    final extractY = yValueExtractor ?? (WellnessEntry e) => e.wellnessScore;
    final xs = <double>[];
    final ys = <double>[];
    for (final e in wellnessEntries) {
      xs.add(e.stressLevel.toDouble());
      ys.add(extractY(e));
    }
    // Need at least SOME variance on both axes, otherwise r is undefined.
    final hasXVariance = xs.any((v) => v != xs.first);
    final hasYVariance = ys.any((v) => v != ys.first);
    if (!hasXVariance || !hasYVariance) return null;

    final r = _spearman(xs, ys);
    final p = _pValueFromR(r, xs.length);
    return StressImpact(
      spearmanR: r,
      pValue: p,
      sampleCount: xs.length,
    );
  }

  /// For each ingredient that appears in [meals], compute a Spearman rank
  /// correlation against wellness scores in [wellnessEntries] across the three
  /// named time zones. Returns scores sorted by |r| * confidence, with
  /// Benjamini–Hochberg FDR-adjusted q-values and an isSignificant flag.
  ///
  /// Why Spearman instead of Pearson: robust to outliers and catches
  /// monotone-but-non-linear relationships (a moderate dose of garlic might
  /// bother the gut more than either tiny or massive amounts do).
  ///
  /// Why BH FDR: with ~115 foods × 3 windows × 5 symptoms = ~1,700 tests,
  /// ~85 would show "p < 0.05" by chance alone. BH keeps the expected false
  /// discovery rate bounded at [fdrThreshold] across the batch.
  static List<ImpactScore> computeImpactScores({
    required List<MealEntry> meals,
    required List<WellnessEntry> wellnessEntries,
    Map<int, String>? ingredientNames,
    Map<int, FoodCategory>? ingredientCategories,
    double Function(WellnessEntry)? yValueExtractor,
    double fdrThreshold = 0.1,
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
      int bestSampleSize = 0;
      final rByLag = <int, double>{};

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
            if (!wellness.recordedAt.isBefore(start) &&
                wellness.recordedAt.isBefore(end)) {
              count++;
            }
          }
          xs.add(count.toDouble());
          ys.add(extractY(wellness));
        }

        if (xs.length < 3) continue;

        final r = _spearman(xs, ys);
        rByLag[zone.from] = r;
        if (r.abs() > bestR.abs()) {
          bestR = r;
          bestZoneFrom = zone.from;
          bestN = xs.where((x) => x > 0).length;
          bestSampleSize = xs.length;
        }
      }

      if (bestN < 3) continue;

      final confidence = (bestN / 20.0).clamp(0.0, 1.0);
      final p = _pValueFromR(bestR, bestSampleSize);

      scores.add(
        ImpactScore(
          ingredientId: ingredientId,
          ingredientName: name,
          category: category,
          pearsonR: bestR,
          bestLagHours: bestZoneFrom,
          sampleCount: bestN,
          confidenceLevel: confidence,
          pearsonByLag: rByLag,
          pValue: p,
        ),
      );
    }

    // ── Benjamini–Hochberg FDR correction ────────────────────────────────────
    final withFdr = _applyBenjaminiHochberg(scores, fdrThreshold);

    withFdr.sort((a, b) => b.rankScore.compareTo(a.rankScore));
    return withFdr;
  }

  // ── Statistics ─────────────────────────────────────────────────────────────

  /// Spearman rank correlation: Pearson r applied to the ranks of x and y.
  /// Handles ties via the "average rank" method.
  static double _spearman(List<double> x, List<double> y) {
    assert(x.length == y.length && x.isNotEmpty);
    return _pearson(_rank(x), _rank(y));
  }

  /// Returns ranks (1-based) with ties averaged. E.g. [10, 20, 20, 30] → [1, 2.5, 2.5, 4].
  static List<double> _rank(List<double> xs) {
    final n = xs.length;
    final indexed =
        List.generate(n, (i) => MapEntry(i, xs[i]))..sort((a, b) => a.value.compareTo(b.value));
    final ranks = List<double>.filled(n, 0.0);
    int i = 0;
    while (i < n) {
      int j = i;
      while (j + 1 < n && indexed[j + 1].value == indexed[i].value) {
        j++;
      }
      // Average rank for the tied group (ranks are 1-based).
      final avg = (i + j + 2) / 2.0;
      for (int k = i; k <= j; k++) {
        ranks[indexed[k].key] = avg;
      }
      i = j + 1;
    }
    return ranks;
  }

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

  /// Two-sided p-value for a correlation r with sample size n, using the
  /// t-distribution approximation: t = r·√((n-2)/(1-r²)) with df = n-2.
  /// Returns 1.0 when not computable (|r| == 1, n < 3, etc.).
  static double _pValueFromR(double r, int n) {
    if (n < 3) return 1.0;
    final rAbs = r.abs().clamp(0.0, 0.999999);
    final df = n - 2;
    final t = rAbs * sqrt(df / (1.0 - rAbs * rAbs));
    return 2.0 * _studentTSf(t, df);
  }

  /// Survival function (1 − CDF) of the Student's-t distribution at t, df > 0.
  /// Computed via the regularized incomplete beta function identity:
  ///   SF(t; df) = 0.5 · I_x(df/2, 1/2)   where x = df/(df+t²).
  static double _studentTSf(double t, int df) {
    final x = df / (df + t * t);
    return 0.5 * _incompleteBeta(x, df / 2.0, 0.5);
  }

  /// Regularized incomplete beta function I_x(a, b) via continued-fraction
  /// expansion (Numerical Recipes, §6.4). Accurate to ~1e-10 for typical inputs.
  static double _incompleteBeta(double x, double a, double b) {
    if (x <= 0.0) return 0.0;
    if (x >= 1.0) return 1.0;
    final lnBeta =
        _logGamma(a) + _logGamma(b) - _logGamma(a + b);
    final front =
        exp(a * log(x) + b * log(1.0 - x) - lnBeta) / a;
    // Use symmetry: the CF converges faster when x < (a+1)/(a+b+2).
    if (x < (a + 1.0) / (a + b + 2.0)) {
      return front * _betaCF(x, a, b);
    } else {
      return 1.0 - exp(b * log(1.0 - x) + a * log(x) - lnBeta) / b *
          _betaCF(1.0 - x, b, a);
    }
  }

  static double _betaCF(double x, double a, double b) {
    const maxIter = 200;
    const eps = 3.0e-12;
    final qab = a + b;
    final qap = a + 1.0;
    final qam = a - 1.0;
    double c = 1.0;
    double d = 1.0 - qab * x / qap;
    if (d.abs() < 1e-30) d = 1e-30;
    d = 1.0 / d;
    double h = d;
    for (int m = 1; m <= maxIter; m++) {
      final m2 = 2 * m;
      var aa = m * (b - m) * x / ((qam + m2) * (a + m2));
      d = 1.0 + aa * d;
      if (d.abs() < 1e-30) d = 1e-30;
      c = 1.0 + aa / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1.0 / d;
      h *= d * c;
      aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
      d = 1.0 + aa * d;
      if (d.abs() < 1e-30) d = 1e-30;
      c = 1.0 + aa / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1.0 / d;
      final del = d * c;
      h *= del;
      if ((del - 1.0).abs() < eps) break;
    }
    return h;
  }

  /// Lanczos approximation to ln(Γ(z)) for z > 0.
  static double _logGamma(double z) {
    const g = 7.0;
    const c = [
      0.99999999999980993,
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7,
    ];
    if (z < 0.5) {
      return log(pi / sin(pi * z)) - _logGamma(1.0 - z);
    }
    final zAdj = z - 1.0;
    double x = c[0];
    for (int i = 1; i < 9; i++) {
      x += c[i] / (zAdj + i);
    }
    final t = zAdj + g + 0.5;
    return 0.5 * log(2.0 * pi) + (zAdj + 0.5) * log(t) - t + log(x);
  }

  /// Benjamini–Hochberg step-up FDR correction over the [scores] batch.
  /// Assigns qValue and flips isSignificant when q ≤ [threshold].
  static List<ImpactScore> _applyBenjaminiHochberg(
    List<ImpactScore> scores,
    double threshold,
  ) {
    final indexed = <int>[];
    final pvals = <double>[];
    for (int i = 0; i < scores.length; i++) {
      final p = scores[i].pValue;
      if (p != null) {
        indexed.add(i);
        pvals.add(p);
      }
    }
    if (pvals.isEmpty) return scores;

    // Sort by p ascending, keep original indices.
    final order = List.generate(pvals.length, (k) => k)
      ..sort((a, b) => pvals[a].compareTo(pvals[b]));
    final m = pvals.length;

    // Compute raw q = p * m / rank, then enforce monotonicity (cumulative min
    // from the largest rank down).
    final rawQ = List<double>.filled(m, 1.0);
    for (int r = 0; r < m; r++) {
      final rank = r + 1;
      rawQ[r] = (pvals[order[r]] * m / rank).clamp(0.0, 1.0);
    }
    for (int r = m - 2; r >= 0; r--) {
      if (rawQ[r + 1] < rawQ[r]) rawQ[r] = rawQ[r + 1];
    }

    final out = List<ImpactScore>.from(scores);
    for (int r = 0; r < m; r++) {
      final originalIdx = indexed[order[r]];
      final q = rawQ[r];
      out[originalIdx] = scores[originalIdx]
          .copyWith(qValue: q, isSignificant: q <= threshold);
    }
    return out;
  }
}
