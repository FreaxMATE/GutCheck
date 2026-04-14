import 'package:isar/isar.dart';

import 'meal_ingredient.dart';

part 'meal_template.g.dart';

@collection
class MealTemplate {
  Id id = Isar.autoIncrement;

  /// User-given name, e.g. "Morning Oatmeal"
  late String name;

  /// Optional default meal label: "Breakfast", "Lunch", "Dinner", "Snack"
  String? mealLabel;

  late List<MealIngredient> ingredients;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
