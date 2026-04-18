import 'package:isar/isar.dart';

part 'wellness_entry_native.g.dart';

@collection
class WellnessEntry {
  Id id = Isar.autoIncrement;

  /// When symptoms were recorded
  @Index()
  late DateTime recordedAt;

  /// Gut discomfort level. Stored as 2× the display value so 0.5-step
  /// resolution fits in an int:  0 = 0.0, 1 = 0.5, 2 = 1.0, ..., 20 = 10.0.
  late int gutPeace;

  /// Heartburn level (0-10 in 0.5 steps, same 2× encoding as gutPeace).
  int heartburn = 0;

  /// Self-reported stress level (0-10 in 0.5 steps, same 2× encoding).
  /// Stress is an INPUT — a context variable, not a symptom output.
  int stressLevel = 0;

  /// Bloating / Aufgeblähtheit — 3-level ordinal (0=Keine, 1=Leicht, 2=Stark).
  /// Coarser than the other sliders because users struggle to distinguish
  /// subtle bloating degrees, and a 3-state input still gives the correlation
  /// engine useful signal via Spearman ranks.
  int bloating = 0;

  /// Whether the user experienced diarrhea.
  bool diarrhea = false;

  /// Composite 0–100 score stored for fast querying.
  late double wellnessScore;

  /// IDs of MealEntry records the user linked to these symptoms.
  List<int> linkedMealIds = [];

  String? notes;

  /// true = inserted by SampleDataService
  bool isSample = false;

  DateTime createdAt = DateTime.now();

  // ── Convenience helpers ────────────────────────────────────────────────
  // The 2× encoding means stored int 0-20 → display double 0.0-10.0.

  // Clamp defensively: pre-migration rows from older Isar schemas may return
  // out-of-range ints for fields that didn't exist on disk. Bounded reads keep
  // radar charts / subtitles sane until the rows are rewritten.
  @ignore
  double get gutPeaceDisplay => gutPeace.clamp(0, 20) / 2.0;
  @ignore
  double get heartburnDisplay => heartburn.clamp(0, 20) / 2.0;
  @ignore
  double get stressDisplay => stressLevel.clamp(0, 20) / 2.0;
  /// Bloating as a 0–10 display value (0/5/10 for none/light/strong) so it
  /// plots on the same axis scale as the other symptom sliders in the radar.
  @ignore
  double get bloatingDisplay => bloating.clamp(0, 2) * 5.0;

  /// Set from a 0.0-10.0 display value.
  void setGutPeaceDisplay(double v) => gutPeace = (v * 2).round().clamp(0, 20);
  void setHeartburnDisplay(double v) =>
      heartburn = (v * 2).round().clamp(0, 20);
  void setStressDisplay(double v) => stressLevel = (v * 2).round().clamp(0, 20);
}
