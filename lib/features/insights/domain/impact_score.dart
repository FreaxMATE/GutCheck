import '../../../core/constants/food_categories.dart';
import 'correlation_engine.dart';

/// Compact result of correlating stress (input) against a symptom metric.
class StressImpact {
  final double correlationR;
  final double pValue;
  final int sampleCount;

  const StressImpact({
    required this.correlationR,
    required this.pValue,
    required this.sampleCount,
  });

  /// Negative r means "more stress → worse wellness" — the intuitive direction.
  bool get isHarmful => correlationR < 0;

  int get correlationPercent => (correlationR.abs() * 100).round();

  /// Cheap confidence heuristic, mirrors ImpactScore's: caps at 20+ samples.
  double get confidenceLevel => (sampleCount / 20.0).clamp(0.0, 1.0);

  /// Pre-FDR threshold. Call sites that display a batch of tests should still
  /// run BH correction themselves; this flag is a simple single-test p < 0.05
  /// heuristic for the solo stress card.
  bool get isNominallySignificant => pValue < 0.05 && sampleCount >= 5;
}

class ImpactScore {
  final int ingredientId;
  final String ingredientName;
  final FoodCategory category;

  /// Spearman rank correlation coefficient: −1.0 (always bad) to +1.0
  /// (always good). 0 = no monotone association.
  final double correlationR;

  /// The zone.from hour (0, 4, or 12) of the zone that produces the strongest |r|.
  final int bestLagHours;

  /// Number of data points used for this correlation.
  final int sampleCount;

  /// 0–1: min(1.0, sampleCount / 20). Discounts sparse data.
  final double confidenceLevel;

  /// Spearman r at each time zone (key = zone.from hours: 0, 4, 12).
  final Map<int, double> correlationByLag;

  /// Two-sided p-value for the best-zone correlation (analytical, from t-dist).
  /// Lower = more unlikely to have occurred by chance. Null when not computed.
  final double? pValue;

  /// Benjamini–Hochberg adjusted q-value across all (ingredient × window × symptom)
  /// tests in the same analysis batch. Null until the engine runs FDR correction.
  final double? qValue;

  /// True when qValue ≤ the chosen FDR threshold (default 0.1).
  /// UI can key off this to separate "confirmed" from "exploratory" patterns.
  final bool isSignificant;

  const ImpactScore({
    required this.ingredientId,
    required this.ingredientName,
    required this.category,
    required this.correlationR,
    required this.bestLagHours,
    required this.sampleCount,
    required this.confidenceLevel,
    this.correlationByLag = const {},
    this.pValue,
    this.qValue,
    this.isSignificant = false,
  });

  ImpactScore copyWith({double? qValue, bool? isSignificant}) => ImpactScore(
        ingredientId: ingredientId,
        ingredientName: ingredientName,
        category: category,
        correlationR: correlationR,
        bestLagHours: bestLagHours,
        sampleCount: sampleCount,
        confidenceLevel: confidenceLevel,
        correlationByLag: correlationByLag,
        pValue: pValue,
        qValue: qValue ?? this.qValue,
        isSignificant: isSignificant ?? this.isSignificant,
      );

  /// Adjusted score used for ranking: |r| * confidence
  double get rankScore => correlationR.abs() * confidenceLevel;

  /// Percentage representation of |r| * 100
  int get correlationPercent => (correlationR.abs() * 100).round();

  /// true if the food is associated with WORSE wellness
  bool get isHarmful => correlationR < 0;

  /// The time zone that produced the best correlation.
  ({int from, int to, String label, String shortLabel}) get bestZone {
    return CorrelationEngine.timeZones.firstWhere(
      (z) => z.from == bestLagHours,
      orElse: () => CorrelationEngine.timeZones.first,
    );
  }

  String get summaryText {
    if (sampleCount < 3) return 'Not enough data yet';
    final pct = correlationPercent;
    final direction = isHarmful ? 'drop' : 'improvement';
    final zone = bestZone;
    return '$pct% correlation with wellness $direction in the ${zone.label} window (${zone.shortLabel} after eating)';
  }
}
