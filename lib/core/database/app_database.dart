import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/models/meal_template.dart';
import '../../features/pantry/data/models/ingredient.dart';
import '../../features/wellness/data/models/wellness_entry.dart';
import '../constants/food_categories.dart';

abstract class AppDatabase {
  Future<void> seedIfNeeded();

  Future<List<Ingredient>> searchIngredients({
    String query = '',
    FoodCategory? category,
    bool customOnly = false,
    int limit = 200,
    int offset = 0,
  });

  Future<int> ingredientCount();
  Future<Ingredient?> findIngredientById(int id);
  Future<Ingredient?> findIngredientByName(String name);
  Future<void> saveIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(int id);
  Future<List<Ingredient>> allIngredients();
  Future<List<Ingredient>> allCustomIngredients();
  Future<void> deleteAllCustomIngredients();

  Future<List<MealEntry>> mealsForDate(DateTime date);
  Future<List<MealEntry>> mealsInRange({
    required DateTime from,
    required DateTime to,
  });
  Future<MealEntry?> findMealById(int id);
  Future<void> saveMeal(MealEntry meal);
  Future<void> saveMeals(List<MealEntry> meals);
  Future<void> deleteMeal(int id);
  Future<List<MealEntry>> allMeals();
  Future<void> deleteAllMeals();
  Future<int> sampleMealCount();
  Future<void> deleteSampleMeals();

  Future<List<WellnessEntry>> wellnessForDate(DateTime date);
  Future<List<WellnessEntry>> wellnessInRange({
    required DateTime from,
    required DateTime to,
  });
  Future<WellnessEntry?> findWellnessById(int id);
  Future<void> saveWellness(WellnessEntry entry);
  Future<void> saveWellnessEntries(List<WellnessEntry> entries);
  Future<void> deleteWellness(int id);
  Future<List<WellnessEntry>> allWellness();
  Future<void> deleteAllWellness();
  Future<void> deleteSampleWellness();

  Future<List<MealTemplate>> allMealTemplates();
  Future<MealTemplate?> findMealTemplateById(int id);
  Future<void> saveMealTemplate(MealTemplate template);
  Future<void> deleteMealTemplate(int id);
  Future<void> deleteAllMealTemplates();
}
