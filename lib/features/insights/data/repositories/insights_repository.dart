import '../../../wellness/data/models/wellness_entry.dart';

class InsightsRepository {
  InsightsRepository._();

  /// Aggregate wellness entries into a daily average map using [scoreExtractor]
  /// (defaults to `entry.wellnessScore`). The extractor should return a
  /// "wellness-like" number in 0-100 where HIGHER = better.
  static Map<DateTime, double> aggregateByDay(
    List<WellnessEntry> entries, {
    double Function(WellnessEntry)? scoreExtractor,
  }) {
    final extract = scoreExtractor ?? (WellnessEntry e) => e.wellnessScore;
    final Map<DateTime, List<double>> groups = {};

    for (final e in entries) {
      final day = DateTime(
          e.recordedAt.year, e.recordedAt.month, e.recordedAt.day);
      groups.putIfAbsent(day, () => []).add(extract(e));
    }

    return groups.map((day, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      return MapEntry(day, avg);
    });
  }
}
