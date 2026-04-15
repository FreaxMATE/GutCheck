import 'package:isar/isar.dart';

part 'meal_ingredient_native.g.dart';

/// Embedded within MealEntry. Stored directly, not as a separate collection.
@embedded
class MealIngredient {
  /// Foreign key to Ingredient.id
  late int ingredientId;

  /// Denormalized snapshot of the name at time of logging
  late String ingredientName;

  /// Free-form quantity string: "1 cup", "2 tbsp", "handful"
  String? quantity;
}
