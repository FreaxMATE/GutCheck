/// Utilities for formatting wellness scores for display.
///
/// Internal storage keeps wellnessScore in 0-100 (higher = better) for
/// correlation math and Pearson r precision. User-facing displays use the
/// friendlier 0-10 scale matching the discomfort input scale.
class WellnessDisplay {
  WellnessDisplay._();

  /// Convert the internal 0-100 wellness score to the 0-10 display value.
  static double toDisplay(double score0to100) => score0to100 / 10.0;

  /// Short label for a single wellness score, e.g. "8" or "8.5".
  static String format(double score0to100, {int decimals = 1}) {
    final v = toDisplay(score0to100);
    // Show whole numbers without a decimal; otherwise 1 decimal place.
    if (v == v.roundToDouble()) return '${v.round()}';
    return v.toStringAsFixed(decimals);
  }

  /// A short suffix for the display, e.g. "/10".
  static const suffix = '/10';
}
