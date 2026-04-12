import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/repositories/meal_repository.dart';
import '../../features/pantry/data/models/ingredient.dart';
import '../../features/pantry/data/repositories/ingredient_repository.dart';
import '../../features/wellness/data/models/wellness_entry.dart';
import '../../features/wellness/data/repositories/wellness_repository.dart';
import '../constants/food_categories.dart';
import 'app_database.dart';
import 'seed_service.dart';

class IsarAppDatabase implements AppDatabase {
  final Isar _isar;

  IsarAppDatabase(this._isar);

  @override
  Future<void> seedIfNeeded() => SeedService(_isar).seedIfNeeded();

  @override
  Future<List<Ingredient>> searchIngredients({
    String query = '',
    FoodCategory? category,
    bool customOnly = false,
    int limit = 200,
    int offset = 0,
  }) {
    return IngredientRepository(_isar).search(
      query: query,
      category: category,
      customOnly: customOnly,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> ingredientCount() => IngredientRepository(_isar).count();

  @override
  Future<Ingredient?> findIngredientById(int id) =>
      IngredientRepository(_isar).findById(id);

  @override
  Future<Ingredient?> findIngredientByName(String name) {
    return _isar.ingredients
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  @override
  Future<void> saveIngredient(Ingredient ingredient) =>
      IngredientRepository(_isar).save(ingredient);

  @override
  Future<void> deleteIngredient(int id) =>
      IngredientRepository(_isar).delete(id);

  @override
  Future<List<Ingredient>> allIngredients() => IngredientRepository(_isar).all();

  @override
  Future<List<Ingredient>> allCustomIngredients() =>
      IngredientRepository(_isar).allCustom();

  @override
  Future<void> deleteAllCustomIngredients() =>
      IngredientRepository(_isar).deleteAllCustom();

  @override
  Future<List<MealEntry>> mealsForDate(DateTime date) =>
      MealRepository(_isar).forDate(date);

  @override
  Future<List<MealEntry>> mealsInRange({required DateTime from, required DateTime to}) =>
      MealRepository(_isar).inRange(from: from, to: to);

  @override
  Future<MealEntry?> findMealById(int id) => MealRepository(_isar).findById(id);

  @override
  Future<void> saveMeal(MealEntry meal) => MealRepository(_isar).save(meal);

  @override
  Future<void> saveMeals(List<MealEntry> meals) async {
    await _isar.writeTxn(() => _isar.mealEntrys.putAll(meals));
  }

  @override
  Future<void> deleteMeal(int id) => MealRepository(_isar).delete(id);

  @override
  Future<List<MealEntry>> allMeals() => MealRepository(_isar).all();

  @override
  Future<void> deleteAllMeals() => MealRepository(_isar).deleteAll();

  @override
  Future<int> sampleMealCount() =>
      _isar.mealEntrys.filter().isSampleEqualTo(true).count();

  @override
  Future<void> deleteSampleMeals() async {
    await _isar.writeTxn(() async {
      await _isar.mealEntrys.filter().isSampleEqualTo(true).deleteAll();
    });
  }

  @override
  Future<List<WellnessEntry>> wellnessForDate(DateTime date) =>
      WellnessRepository(_isar).forDate(date);

  @override
  Future<List<WellnessEntry>> wellnessInRange({
    required DateTime from,
    required DateTime to,
  }) =>
      WellnessRepository(_isar).inRange(from: from, to: to);

  @override
  Future<WellnessEntry?> findWellnessById(int id) async {
    final all = await WellnessRepository(_isar).all();
    for (final entry in all) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<void> saveWellness(WellnessEntry entry) =>
      WellnessRepository(_isar).save(entry);

  @override
  Future<void> saveWellnessEntries(List<WellnessEntry> entries) async {
    await _isar.writeTxn(() => _isar.wellnessEntrys.putAll(entries));
  }

  @override
  Future<void> deleteWellness(int id) => WellnessRepository(_isar).delete(id);

  @override
  Future<List<WellnessEntry>> allWellness() => WellnessRepository(_isar).all();

  @override
  Future<void> deleteAllWellness() => WellnessRepository(_isar).deleteAll();

  @override
  Future<void> deleteSampleWellness() async {
    await _isar.writeTxn(() async {
      await _isar.wellnessEntrys.filter().isSampleEqualTo(true).deleteAll();
    });
  }
}

Future<AppDatabase> createAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [IngredientSchema, MealEntrySchema, WellnessEntrySchema],
    directory: dir.path,
  );
  final db = IsarAppDatabase(isar);
  await db.seedIfNeeded();
  return db;
}
