import 'package:isar/isar.dart';

part 'wellness_entry_native.g.dart';

@collection
class WellnessEntry {
  Id id = Isar.autoIncrement;

  /// When symptoms were recorded
  @Index()
  late DateTime recordedAt;

  /// Overall gut comfort. 1 = very uncomfortable, 10 = perfect.
  late int gutPeace;

  /// Heartburn intensity. 1 = none, 10 = severe. Defaults to 1 for old records.
  int heartburn = 1;

  /// Whether the user experienced diarrhea. Defaults to false for old records.
  bool diarrhea = false;

  /// Composite 0–100 score stored for fast querying.
  late double wellnessScore;

  /// IDs of MealEntry records the user linked to these symptoms.
  List<int> linkedMealIds = [];

  String? notes;

  /// true = inserted by SampleDataService
  bool isSample = false;

  DateTime createdAt = DateTime.now();
}
