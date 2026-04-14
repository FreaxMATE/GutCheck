import 'meal_ingredient.dart';

class MealTemplate {
  int id = 0;

  /// User-given name, e.g. "Morning Oatmeal"
  String name = '';

  /// Optional default meal label: "Breakfast", "Lunch", "Dinner", "Snack"
  String? mealLabel;

  List<MealIngredient> ingredients = [];

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
