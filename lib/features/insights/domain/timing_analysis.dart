import '../../meal_log/data/models/meal_entry.dart';
import '../../wellness/data/models/wellness_entry.dart';

/// Result for one time-of-day bucket.
class TimingBucketResult {
  final String label;
  final String shortLabel;
  final int startHour;
  final int endHour;
  final int mealCount;
  final double avgDiscomfort; // 0-10
  final double avgWellnessScore; // 0-100 (higher = better)

  const TimingBucketResult({
    required this.label,
    required this.shortLabel,
    required this.startHour,
    required this.endHour,
    required this.mealCount,
    required this.avgDiscomfort,
    required this.avgWellnessScore,
  });
}

/// Full timing analysis output.
class TimingAnalysis {
  final List<TimingBucketResult> buckets;

  /// The bucket with the lowest average discomfort (best time to eat).
  final TimingBucketResult? bestBucket;

  /// The bucket with the highest average discomfort (worst time to eat).
  final TimingBucketResult? worstBucket;

  /// Average gap between consecutive meals (hours), or null if < 2 meals.
  final double? avgMealGapHours;

  /// Late-eating penalty: avg discomfort for meals after 9pm minus before 7pm.
  /// Positive = late eating hurts. Null if insufficient data.
  final double? lateEatingPenalty;

  const TimingAnalysis({
    required this.buckets,
    this.bestBucket,
    this.worstBucket,
    this.avgMealGapHours,
    this.lateEatingPenalty,
  });
}

class TimingAnalyzer {
  TimingAnalyzer._();

  static const _bucketDefs = [
    (label: 'Early morning', short: '6–9', start: 6, end: 9),
    (label: 'Late morning', short: '9–12', start: 9, end: 12),
    (label: 'Midday', short: '12–14', start: 12, end: 14),
    (label: 'Afternoon', short: '14–17', start: 14, end: 17),
    (label: 'Early evening', short: '17–20', start: 17, end: 20),
    (label: 'Late evening', short: '20–22', start: 20, end: 22),
    (label: 'Night', short: '22+', start: 22, end: 6), // wraps
  ];

  /// Analyze correlation between WHEN the user eats and how they feel
  /// in the 4-12h window after the meal.
  static TimingAnalysis analyze({
    required List<MealEntry> meals,
    required List<WellnessEntry> wellness,
  }) {
    if (meals.isEmpty || wellness.isEmpty) {
      return const TimingAnalysis(buckets: []);
    }

    // For each meal, find wellness entries in the 4-12h window after it
    // and compute the average discomfort.
    final Map<int, List<double>> bucketDiscomforts = {};

    for (final meal in meals) {
      final bucketIdx = _bucketFor(meal.consumedAt.hour);
      final windowStart = meal.consumedAt.add(const Duration(hours: 4));
      final windowEnd = meal.consumedAt.add(const Duration(hours: 12));

      final matched = wellness.where((w) =>
          !w.recordedAt.isBefore(windowStart) &&
          w.recordedAt.isBefore(windowEnd));

      if (matched.isNotEmpty) {
        // Use display values (0.0-10.0) for the average.
        final avgD =
            matched.map((w) => w.gutPeaceDisplay).reduce((a, b) => a + b) /
                matched.length;
        bucketDiscomforts.putIfAbsent(bucketIdx, () => []).add(avgD);
      }
    }

    // Build results per bucket.
    final results = <TimingBucketResult>[];
    for (int i = 0; i < _bucketDefs.length; i++) {
      final def = _bucketDefs[i];
      final scores = bucketDiscomforts[i];
      if (scores == null || scores.isEmpty) continue;
      final avgD = scores.reduce((a, b) => a + b) / scores.length;
      results.add(TimingBucketResult(
        label: def.label,
        shortLabel: def.short,
        startHour: def.start,
        endHour: def.end,
        mealCount: scores.length,
        avgDiscomfort: avgD,
        avgWellnessScore: ((10 - avgD) / 10) * 100,
      ));
    }

    results.sort((a, b) => a.startHour.compareTo(b.startHour));

    final best = results.isEmpty
        ? null
        : results.reduce((a, b) =>
            a.avgDiscomfort <= b.avgDiscomfort ? a : b);
    final worst = results.isEmpty
        ? null
        : results.reduce((a, b) =>
            a.avgDiscomfort >= b.avgDiscomfort ? a : b);

    // Average meal gap.
    double? avgGap;
    if (meals.length >= 2) {
      final sorted = [...meals]
        ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
      double totalGap = 0;
      int gapCount = 0;
      for (int i = 1; i < sorted.length; i++) {
        final gap = sorted[i]
            .consumedAt
            .difference(sorted[i - 1].consumedAt)
            .inMinutes;
        // Only count intra-day gaps (< 18h).
        if (gap > 30 && gap < 18 * 60) {
          totalGap += gap;
          gapCount++;
        }
      }
      if (gapCount > 0) avgGap = totalGap / gapCount / 60;
    }

    // Late-eating penalty: avg discomfort after-9pm minus before-7pm.
    double? lateEatingPenalty;
    final late9 = bucketDiscomforts[5] ?? []; // 20-22
    final late10 = bucketDiscomforts[6] ?? []; // 22+
    final lateAll = [...late9, ...late10];
    final early = bucketDiscomforts[0] ?? []; // 6-9
    if (lateAll.length >= 2 && early.length >= 2) {
      final avgLate = lateAll.reduce((a, b) => a + b) / lateAll.length;
      final avgEarly = early.reduce((a, b) => a + b) / early.length;
      lateEatingPenalty = avgLate - avgEarly;
    }

    return TimingAnalysis(
      buckets: results,
      bestBucket: best,
      worstBucket: worst,
      avgMealGapHours: avgGap,
      lateEatingPenalty: lateEatingPenalty,
    );
  }

  static int _bucketFor(int hour) {
    if (hour >= 22 || hour < 6) return 6; // Night
    if (hour < 9) return 0;
    if (hour < 12) return 1;
    if (hour < 14) return 2;
    if (hour < 17) return 3;
    if (hour < 20) return 4;
    return 5; // 20-22
  }
}
