import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/models/meal_ingredient.dart';
import '../../features/pantry/data/models/ingredient.dart';
import '../../features/wellness/data/models/wellness_entry.dart';
import '../constants/food_categories.dart';
import 'app_database.dart';

class HiveAppDatabase implements AppDatabase {
  static const _seedVersionKey = 'seed_version';
  static const _seedVersion = 2;

  final Box<String> _ingredients;
  final Box<String> _meals;
  final Box<String> _wellness;

  HiveAppDatabase(this._ingredients, this._meals, this._wellness);

  @override
  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_seedVersionKey) ?? 0;
    if (current >= _seedVersion) return;

    final raw = await rootBundle.loadString('assets/seed/ingredients.json');
    final decoded = jsonDecode(raw);
    final List<dynamic> list = decoded is Map
        ? (decoded['ingredients'] as List<dynamic>? ?? [])
        : decoded as List<dynamic>;

    for (final item in list) {
      final j = item as Map<String, dynamic>;
      final ingredient = Ingredient()
        ..name = j['name'] as String
        ..nameLower = (j['name'] as String).toLowerCase()
        ..category = _categoryFromJson(j['category'])
        ..secondaryCategoryName = j['secondaryCategory'] as String?
        ..nameDE = j['nameDE'] as String?
        ..fodmapLevel = ((j['fodmapLevel'] ?? j['fodmap']) as String).toLowerCase()
        ..isSeeded = true
        ..createdAt = DateTime.now();
      await saveIngredient(ingredient);
    }

    await prefs.setInt(_seedVersionKey, _seedVersion);
  }

  @override
  Future<List<Ingredient>> searchIngredients({
    String query = '',
    FoodCategory? category,
    int limit = 200,
    int offset = 0,
  }) async {
    final lower = query.trim().toLowerCase();
    final all = await allIngredients();
    var filtered = all.where((ingredient) {
      final categoryOk = category == null || ingredient.category == category;
      // Search both English (nameLower) and German (nameDE) names
      final queryOk = lower.isEmpty ||ingredient.nameLower.contains(lower) || (ingredient.nameDE?.toLowerCase().contains(lower) ?? false);
      return categoryOk && queryOk;
    }).toList()
      ..sort((a, b) => a.nameLower.compareTo(b.nameLower));

    if (offset >= filtered.length) return [];
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(offset, end);
  }

  @override
  Future<int> ingredientCount() async => _ingredients.length;

  @override
  Future<Ingredient?> findIngredientById(int id) async {
    final raw = _ingredients.get(id.toString());
    if (raw == null) return null;
    return _ingredientFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<Ingredient?> findIngredientByName(String name) async {
    final target = name.toLowerCase();
    final ingredients = await allIngredients();
    for (final ingredient in ingredients) {
      if (ingredient.nameLower == target) {
        return ingredient;
      }
    }
    return null;
  }

  @override
  Future<void> saveIngredient(Ingredient ingredient) async {
    if (ingredient.id <= 0) {
      ingredient.id = _nextId(_ingredients);
    }
    if (ingredient.nameLower.isEmpty) {
      ingredient.nameLower = ingredient.name.toLowerCase();
    }
    await _ingredients.put(
      ingredient.id.toString(),
      jsonEncode(_ingredientToJson(ingredient)),
    );
  }

  @override
  Future<void> deleteIngredient(int id) => _ingredients.delete(id.toString());

  @override
  Future<List<Ingredient>> allIngredients() async {
    final list = _ingredients.values
        .map((value) =>
            _ingredientFromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.nameLower.compareTo(b.nameLower));
    return list;
  }

  @override
  Future<List<Ingredient>> allCustomIngredients() async {
    final all = await allIngredients();
    return all.where((i) => !i.isSeeded).toList();
  }

  @override
  Future<void> deleteAllCustomIngredients() async {
    final customs = await allCustomIngredients();
    await _ingredients.deleteAll(customs.map((e) => e.id.toString()));
  }

  @override
  Future<List<MealEntry>> mealsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final meals = await mealsInRange(from: start, to: end);
    meals.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    return meals;
  }

  @override
  Future<List<MealEntry>> mealsInRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final meals = (await allMeals())
        .where((m) =>
            !m.consumedAt.isBefore(from) && m.consumedAt.isBefore(to))
        .toList()
      ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    return meals;
  }

  @override
  Future<MealEntry?> findMealById(int id) async {
    final raw = _meals.get(id.toString());
    if (raw == null) return null;
    return _mealFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveMeal(MealEntry meal) async {
    if (meal.id <= 0) {
      meal.id = _nextId(_meals);
    }
    await _meals.put(meal.id.toString(), jsonEncode(_mealToJson(meal)));
  }

  @override
  Future<void> saveMeals(List<MealEntry> meals) async {
    for (final meal in meals) {
      await saveMeal(meal);
    }
  }

  @override
  Future<void> deleteMeal(int id) => _meals.delete(id.toString());

  @override
  Future<List<MealEntry>> allMeals() async {
    final list = _meals.values
        .map((value) => _mealFromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    return list;
  }

  @override
  Future<void> deleteAllMeals() => _meals.clear();

  @override
  Future<int> sampleMealCount() async {
    final all = await allMeals();
    return all.where((m) => m.isSample).length;
  }

  @override
  Future<void> deleteSampleMeals() async {
    final all = await allMeals();
    await _meals.deleteAll(
      all.where((m) => m.isSample).map((m) => m.id.toString()),
    );
  }

  @override
  Future<List<WellnessEntry>> wellnessForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final wellness = await wellnessInRange(from: start, to: end);
    wellness.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return wellness;
  }

  @override
  Future<List<WellnessEntry>> wellnessInRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final all = await allWellness();
    final list = all
        .where((w) => !w.recordedAt.isBefore(from) && w.recordedAt.isBefore(to))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return list;
  }

  @override
  Future<WellnessEntry?> findWellnessById(int id) async {
    final raw = _wellness.get(id.toString());
    if (raw == null) return null;
    return _wellnessFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveWellness(WellnessEntry entry) async {
    if (entry.id <= 0) {
      entry.id = _nextId(_wellness);
    }
    await _wellness.put(entry.id.toString(), jsonEncode(_wellnessToJson(entry)));
  }

  @override
  Future<void> saveWellnessEntries(List<WellnessEntry> entries) async {
    for (final entry in entries) {
      await saveWellness(entry);
    }
  }

  @override
  Future<void> deleteWellness(int id) => _wellness.delete(id.toString());

  @override
  Future<List<WellnessEntry>> allWellness() async {
    final list = _wellness.values
        .map((value) =>
            _wellnessFromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return list;
  }

  @override
  Future<void> deleteAllWellness() => _wellness.clear();

  @override
  Future<void> deleteSampleWellness() async {
    final all = await allWellness();
    await _wellness.deleteAll(
      all.where((w) => w.isSample).map((w) => w.id.toString()),
    );
  }

  int _nextId(Box<String> box) {
    int maxId = 0;
    for (final key in box.keys) {
      final id = int.tryParse(key.toString()) ?? 0;
      if (id > maxId) {
        maxId = id;
      }
    }
    return maxId + 1;
  }

  static Map<String, dynamic> _ingredientToJson(Ingredient ingredient) => {
        'id': ingredient.id,
        'name': ingredient.name,
        'nameLower': ingredient.nameLower,
        'category': ingredient.category.name,
        'fodmapLevel': ingredient.fodmapLevel,
        'isSeeded': ingredient.isSeeded,
        'secondaryCategoryName': ingredient.secondaryCategoryName,
        'nameDE': ingredient.nameDE,
        'photoPath': ingredient.photoPath,
        'notes': ingredient.notes,
        'createdAt': ingredient.createdAt.toIso8601String(),
      };

  static Ingredient _ingredientFromJson(Map<String, dynamic> json) {
    return Ingredient()
      ..id = json['id'] as int
      ..name = json['name'] as String
      ..nameLower = (json['nameLower'] as String?) ??
          (json['name'] as String).toLowerCase()
      ..category = _categoryFromJson(json['category'])
      ..fodmapLevel = (json['fodmapLevel'] as String?) ?? 'moderate'
      ..isSeeded = (json['isSeeded'] as bool?) ?? false
      ..secondaryCategoryName = json['secondaryCategoryName'] as String?
      ..nameDE = json['nameDE'] as String?
      ..photoPath = json['photoPath'] as String?
      ..notes = json['notes'] as String?
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now();
  }

  static Map<String, dynamic> _mealToJson(MealEntry meal) => {
        'id': meal.id,
        'consumedAt': meal.consumedAt.toIso8601String(),
        'mealLabel': meal.mealLabel,
        'ingredients': meal.ingredients
            .map((ingredient) => {
                  'ingredientId': ingredient.ingredientId,
                  'ingredientName': ingredient.ingredientName,
                  'quantity': ingredient.quantity,
                })
            .toList(),
        'photoPath': meal.photoPath,
        'notes': meal.notes,
        'isSample': meal.isSample,
        'createdAt': meal.createdAt.toIso8601String(),
      };

  static MealEntry _mealFromJson(Map<String, dynamic> json) {
    final ingredientsJson = (json['ingredients'] as List<dynamic>? ?? []);
    return MealEntry()
      ..id = json['id'] as int
      ..consumedAt = DateTime.tryParse(json['consumedAt'] as String? ?? '') ??
          DateTime.now()
      ..mealLabel = json['mealLabel'] as String?
      ..ingredients = ingredientsJson
          .map((value) => _mealIngredientFromJson(value as Map<String, dynamic>))
          .toList()
      ..photoPath = json['photoPath'] as String?
      ..notes = json['notes'] as String?
      ..isSample = (json['isSample'] as bool?) ?? false
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now();
  }

  static MealIngredient _mealIngredientFromJson(Map<String, dynamic> json) {
    return MealIngredient()
      ..ingredientId = json['ingredientId'] as int
      ..ingredientName = json['ingredientName'] as String
      ..quantity = json['quantity'] as String?;
  }

  static Map<String, dynamic> _wellnessToJson(WellnessEntry entry) => {
        'id': entry.id,
        'recordedAt': entry.recordedAt.toIso8601String(),
        'gutPeace': entry.gutPeace,
        'heartburn': entry.heartburn,
        'diarrhea': entry.diarrhea,
        'wellnessScore': entry.wellnessScore,
        'linkedMealIds': entry.linkedMealIds,
        'notes': entry.notes,
        'isSample': entry.isSample,
        'createdAt': entry.createdAt.toIso8601String(),
      };

  static WellnessEntry _wellnessFromJson(Map<String, dynamic> json) {
    return WellnessEntry()
      ..id = json['id'] as int
      ..recordedAt = DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now()
      ..gutPeace = (json['gutPeace'] as int?) ?? 5
      ..heartburn = (json['heartburn'] as int?) ?? 1
      ..diarrhea = (json['diarrhea'] as bool?) ?? false
      ..wellnessScore = (json['wellnessScore'] as num?)?.toDouble() ?? 50.0
      ..linkedMealIds = (json['linkedMealIds'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList()
      ..notes = json['notes'] as String?
      ..isSample = (json['isSample'] as bool?) ?? false
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now();
  }

  static FoodCategory _categoryFromJson(Object? value) {
    if (value is String) {
      try {
        return FoodCategory.values.byName(value);
      } catch (_) {
        return FoodCategory.other;
      }
    }
    return FoodCategory.other;
  }
}

Future<AppDatabase> createAppDatabase() async {
  await Hive.initFlutter();
  final ingredients = await Hive.openBox<String>('ingredients');
  final meals = await Hive.openBox<String>('meals');
  final wellness = await Hive.openBox<String>('wellness_entries');
  final db = HiveAppDatabase(ingredients, meals, wellness);
  await db.seedIfNeeded();
  return db;
}
