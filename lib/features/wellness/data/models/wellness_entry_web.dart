/// Web fallback for WellnessEntry. Mirrors the native Isar model's fields.
class WellnessEntry {
  int id = 0;
  DateTime recordedAt = DateTime.now();

  /// Gut discomfort. Stored as 2× display value (0-20 = 0.0-10.0 in 0.5 steps).
  int gutPeace = 0;

  /// Heartburn (0-20, 2× encoding).
  int heartburn = 0;

  /// Stress level (0-20, 2× encoding). Input context variable.
  int stressLevel = 0;

  /// Bloating / Aufgeblähtheit — 3-level ordinal (0=Keine, 1=Leicht, 2=Stark).
  int bloating = 0;

  bool diarrhea = false;
  double wellnessScore = 100.0;
  List<int> linkedMealIds = [];
  String? notes;
  bool isSample = false;
  DateTime createdAt = DateTime.now();

  // Display helpers matching native model.
  double get gutPeaceDisplay => gutPeace.clamp(0, 20) / 2.0;
  double get heartburnDisplay => heartburn.clamp(0, 20) / 2.0;
  double get stressDisplay => stressLevel.clamp(0, 20) / 2.0;
  double get bloatingDisplay => bloating.clamp(0, 2) * 5.0;

  void setGutPeaceDisplay(double v) => gutPeace = (v * 2).round().clamp(0, 20);
  void setHeartburnDisplay(double v) =>
      heartburn = (v * 2).round().clamp(0, 20);
  void setStressDisplay(double v) => stressLevel = (v * 2).round().clamp(0, 20);
}
