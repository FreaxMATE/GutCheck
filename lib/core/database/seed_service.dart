import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/food_categories.dart';
import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/models/meal_template.dart';
import '../../features/pantry/data/models/ingredient.dart';

class SeedService {
  final Isar _isar;

  SeedService(this._isar);

  static const _seedVersionKey = 'seed_version';
  static const _currentSeedVersion = 13; // bumped: added flour types (wheat, whole wheat, spelt, rye, rice, almond, coconut, buckwheat, oat, chickpea, cornmeal, cornstarch, tapioca, semolina)
  static const _stableIdMigrationKey = 'stable_id_migration_v1';

  /// FNV-1a 64-bit hash (shifted into positive 63-bit range). Stable across
  /// Dart versions because it only uses codeUnitAt + arithmetic. Used to turn
  /// an ingredient's English name into a deterministic Isar Id — so seeded
  /// ingredients keep the same Id across every seed bump.
  static int stableIdFor(String name) {
    int hash = 0xcbf29ce484222325;
    for (int i = 0; i < name.length; i++) {
      hash ^= name.codeUnitAt(i);
      hash = (hash * 0x100000001b3) & 0x7FFFFFFFFFFFFFFF;
    }
    return hash == 0 ? 1 : hash;
  }

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getInt(_seedVersionKey) ?? 0;

    // One-shot migration (runs once ever): rewrite old meal-ingredient
    // references to use the new stable IDs, so existing logs don't break.
    if (!(prefs.getBool(_stableIdMigrationKey) ?? false)) {
      await _migrateToStableIds();
      await prefs.setBool(_stableIdMigrationKey, true);
    }

    if (seeded >= _currentSeedVersion) return;

    // Upsert the seeded set. Because IDs are deterministic, `putAll` updates
    // existing rows in place and preserves references from meals/templates.
    final jsonStr = await rootBundle.loadString('assets/seed/ingredients.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final items = (data['ingredients'] as List)
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList();
    final newIds = items.map((i) => i.id).toSet();

    await _isar.writeTxn(() async {
      // Remove old seeded ingredients that no longer appear in the JSON
      // (renamed or deleted). Never touches user-created ingredients.
      final stale = await _isar.ingredients
          .filter()
          .isSeededEqualTo(true)
          .findAll();
      final toDelete = stale
          .where((s) => !newIds.contains(s.id))
          .map((s) => s.id)
          .toList();
      if (toDelete.isNotEmpty) {
        await _isar.ingredients.deleteAll(toDelete);
      }
      await _isar.ingredients.putAll(items);
    });

    await prefs.setInt(_seedVersionKey, _currentSeedVersion);
  }

  /// Rewrites every MealEntry.ingredients[].ingredientId and
  /// MealTemplate.ingredients[].ingredientId to the new stable ID computed
  /// from the denormalized `ingredientName`.
  ///
  /// After this runs, all past meals reference stable IDs that match the
  /// newly-seeded ingredients, even if the old auto-incremented IDs were
  /// garbage-collected.
  Future<void> _migrateToStableIds() async {
    final meals = await _isar.mealEntrys.where().findAll();
    final templates = await _isar.mealTemplates.where().findAll();
    if (meals.isEmpty && templates.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final meal in meals) {
        for (final mi in meal.ingredients) {
          mi.ingredientId = stableIdFor(mi.ingredientName);
        }
      }
      for (final t in templates) {
        for (final mi in t.ingredients) {
          mi.ingredientId = stableIdFor(mi.ingredientName);
        }
      }
      if (meals.isNotEmpty) await _isar.mealEntrys.putAll(meals);
      if (templates.isNotEmpty) await _isar.mealTemplates.putAll(templates);
    });
  }

  Ingredient _fromJson(Map<String, dynamic> j) {
    final name = j['name'] as String;
    return Ingredient()
      ..id = stableIdFor(name)
      ..name = name
      ..nameLower = name.toLowerCase()
      ..nameDE = j['nameDE'] as String?
      ..category = FoodCategory.values.byName(j['category'] as String)
      ..secondaryCategoryName = j['secondaryCategory'] as String?
      ..fodmapLevel = j['fodmapLevel'] as String
      ..isSeeded = true;
  }
}
