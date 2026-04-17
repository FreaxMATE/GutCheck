import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/food_categories.dart';
import '../../features/pantry/data/models/ingredient.dart';

class SeedService {
  final Isar _isar;

  SeedService(this._isar);

  static const _seedVersionKey = 'seed_version';
  static const _currentSeedVersion = 8;

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getInt(_seedVersionKey) ?? 0;
    if (seeded >= _currentSeedVersion) return;

    // On every upgrade, replace all seeded ingredients with the curated set.
    // Custom (user-created) ingredients are preserved (isSeeded == false).
    await _isar.writeTxn(() async {
      await _isar.ingredients.filter().isSeededEqualTo(true).deleteAll();
    });

    final jsonStr =
        await rootBundle.loadString('assets/seed/ingredients.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final items = (data['ingredients'] as List)
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList();

    await _isar.writeTxn(() async {
      await _isar.ingredients.putAll(items);
    });

    await prefs.setInt(_seedVersionKey, _currentSeedVersion);
  }

  Ingredient _fromJson(Map<String, dynamic> j) {
    return Ingredient()
      ..name = j['name'] as String
      ..nameLower = (j['name'] as String).toLowerCase()
      ..nameDE = j['nameDE'] as String?
      ..category = FoodCategory.values.byName(j['category'] as String)
      ..secondaryCategoryName = j['secondaryCategory'] as String?
      ..fodmapLevel = j['fodmapLevel'] as String
      ..isSeeded = true;
  }
}
