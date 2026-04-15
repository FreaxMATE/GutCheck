import 'package:isar/isar.dart';

import 'meal_ingredient.dart';

part 'meal_entry_native.g.dart';

@collection
class MealEntry {
  Id id = Isar.autoIncrement;

  /// When the meal was consumed (user-editable, defaults to now)
  @Index()
  late DateTime consumedAt;

  /// "Breakfast", "Lunch", "Dinner", "Snack"
  String? mealLabel;

  late List<MealIngredient> ingredients;

  String? photoPath;
  String? notes;

  /// true = inserted by SampleDataService
  bool isSample = false;

  DateTime createdAt = DateTime.now();
}
