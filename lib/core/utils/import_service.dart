import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/food_categories.dart';
import '../database/app_database.dart';
import '../database/app_database_provider.dart';
import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/models/meal_ingredient.dart';
import '../../features/meal_log/data/models/meal_template.dart';
import '../../features/pantry/data/models/ingredient.dart';
import '../../features/wellness/data/models/wellness_entry.dart';

enum ImportMode { replace, merge }

class ImportResult {
  final bool success;
  final String message;
  final int ingredientsAdded;
  final int mealsAdded;
  final int wellnessEntriesAdded;

  ImportResult({
    required this.success,
    required this.message,
    required this.ingredientsAdded,
    required this.mealsAdded,
    required this.wellnessEntriesAdded,
  });
}

class ImportService {
  ImportService._();

  /// Imports data from a JSON backup file.
  /// [mode] determines whether to replace all data (default) or merge with existing.
  static Future<ImportResult> importFromJson(
    WidgetRef ref,
    String jsonString,
    ImportMode mode,
  ) async {
    try {
      final Map<String, dynamic> payload = jsonDecode(jsonString);

      // Validate version. We currently support v1 (legacy) and v2 (current).
      final version = payload['version'] as int? ?? 1;
      if (version < 1 || version > 2) {
        throw FormatException('Unsupported backup version: $version');
      }

      final db = await ref.read(appDatabaseProvider.future);

      if (mode == ImportMode.replace) {
        return _importReplace(db, payload, version);
      } else {
        return _importMerge(db, payload, version);
      }
    } on FormatException catch (e) {
      return ImportResult(
        success: false,
        message: 'Invalid backup file format: ${e.message}',
        ingredientsAdded: 0,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
        ingredientsAdded: 0,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    }
  }

  /// Imports only custom ingredients from a JSON file (pantry-specific backup
  /// or a full backup — whichever contains a `customIngredients` key).
  static Future<ImportResult> importPantryFromJson(
    WidgetRef ref,
    String jsonString,
  ) async {
    try {
      final Map<String, dynamic> payload = jsonDecode(jsonString);
      // Accept version 1 or any file that has a customIngredients key
      if (payload['customIngredients'] is! List) {
        throw const FormatException('No customIngredients found in file');
      }
      final db = await ref.read(appDatabaseProvider.future);
      int ingredientsAdded = 0;
      final ingredients = payload['customIngredients'] as List;
      for (final item in ingredients) {
        try {
          final existing = await db.findIngredientById(item['id'] as int);
          if (existing == null) {
            final ingredient = Ingredient()
              ..id = item['id'] as int
              ..name = item['name'] as String
              ..nameLower = (item['name'] as String).toLowerCase()
              ..category = FoodCategory.values.firstWhere(
                (e) => e.name == item['category'],
                orElse: () => FoodCategory.other,
              )
              ..fodmapLevel = item['fodmapLevel'] as String? ?? 'moderate'
              ..notes = item['notes'] as String?
              ..createdAt = DateTime.parse(item['createdAt'] as String)
              ..isSeeded = false;
            await db.saveIngredient(ingredient);
            ingredientsAdded++;
          }
        } catch (_) {
          continue;
        }
      }
      return ImportResult(
        success: true,
        message: 'Added $ingredientsAdded custom ingredient(s)',
        ingredientsAdded: ingredientsAdded,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    } on FormatException catch (e) {
      return ImportResult(
        success: false,
        message: 'Invalid file: ${e.message}',
        ingredientsAdded: 0,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
        ingredientsAdded: 0,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    }
  }

  /// Converts a legacy (v1) gutPeace value (1-10, higher = better) to the
  /// current v2 discomfort value (0-10, higher = worse).
  /// For v2+ payloads, returns the value unchanged.
  static int _migrateGutPeace(int value, int payloadVersion) {
    if (payloadVersion >= 2) return value.clamp(0, 10);
    final peace = value.clamp(1, 10);
    return ((10 - peace) * 10 / 9).round().clamp(0, 10);
  }

  static double _wellnessScoreFor(int discomfort) =>
      ((10 - discomfort.clamp(0, 10)) / 10.0) * 100.0;

  /// Replace mode: clear all existing data and restore from backup
  static Future<ImportResult> _importReplace(
    AppDatabase db,
    Map<String, dynamic> payload,
    int payloadVersion,
  ) async {
    int ingredientsAdded = 0;
    int mealsAdded = 0;
    int wellnessEntriesAdded = 0;

    try {
      // Clear all existing data
      await db.deleteAllMeals();
      await db.deleteAllWellness();
      await db.deleteAllCustomIngredients();

      // Restore custom ingredients
      if (payload['customIngredients'] is List) {
        final ingredients = payload['customIngredients'] as List;
        for (final item in ingredients) {
          try {
            final ingredient = Ingredient()
              ..id = item['id'] as int
              ..name = item['name'] as String
              ..nameLower = (item['name'] as String).toLowerCase()
              ..category = FoodCategory.values.firstWhere(
                (e) => e.name == item['category'],
                orElse: () => FoodCategory.other,
              )
              ..fodmapLevel = item['fodmapLevel'] as String? ?? 'moderate'
              ..notes = item['notes'] as String?
              ..createdAt = DateTime.parse(item['createdAt'] as String)
              ..isSeeded = false;
            await db.saveIngredient(ingredient);
            ingredientsAdded++;
          } catch (e) {
            continue; // Skip malformed entries
          }
        }
      }

      // Restore meal entries
      if (payload['mealEntries'] is List) {
        final meals = payload['mealEntries'] as List;
        for (final item in meals) {
          try {
            final mealIngredients = (item['ingredients'] as List?)
                    ?.map((i) {
                      final mi = MealIngredient()
                        ..ingredientId = i['ingredientId'] as int
                        ..ingredientName = i['ingredientName'] as String
                        ..quantity = i['quantity'] as String?;
                      return mi;
                    })
                    .toList() ??
                [];

            final meal = MealEntry()
              ..id = item['id'] as int
              ..consumedAt = DateTime.parse(item['consumedAt'] as String)
              ..mealLabel = item['mealLabel'] as String?
              ..ingredients = mealIngredients
              ..notes = item['notes'] as String?
              ..createdAt = DateTime.parse(item['createdAt'] as String);
            await db.saveMeal(meal);
            mealsAdded++;
          } catch (e) {
            continue;
          }
        }
      }

      // Restore wellness entries
      if (payload['wellnessEntries'] is List) {
        final wellness = payload['wellnessEntries'] as List;
        for (final item in wellness) {
          try {
            final linkedMealIds = (item['linkedMealIds'] as List?)
                    ?.cast<int>()
                    .toList() ??
                [];

            final rawGutPeace =
                item['gutPeace'] as int? ?? (payloadVersion >= 2 ? 0 : 5);
            final migratedGutPeace =
                _migrateGutPeace(rawGutPeace, payloadVersion);
            final entry = WellnessEntry()
              ..id = item['id'] as int
              ..recordedAt = DateTime.parse(item['recordedAt'] as String)
              ..gutPeace = migratedGutPeace
              ..heartburn = item['heartburn'] as int? ?? 1
              ..diarrhea = item['diarrhea'] as bool? ?? false
              // Recompute wellnessScore from the migrated gutPeace so legacy
              // imports get a consistent value matching the new semantics.
              ..wellnessScore = _wellnessScoreFor(migratedGutPeace)
              ..linkedMealIds = linkedMealIds
              ..notes = item['notes'] as String?
              ..createdAt = DateTime.parse(item['createdAt'] as String);
            await db.saveWellness(entry);
            wellnessEntriesAdded++;
          } catch (e) {
            continue;
          }
        }
      }

      // Restore meal templates
      await db.deleteAllMealTemplates();
      if (payload['mealTemplates'] is List) {
        final templates = payload['mealTemplates'] as List;
        for (final item in templates) {
          try {
            final templateIngredients = (item['ingredients'] as List?)
                    ?.map((i) {
                      final mi = MealIngredient()
                        ..ingredientId = i['ingredientId'] as int
                        ..ingredientName = i['ingredientName'] as String
                        ..quantity = i['quantity'] as String?;
                      return mi;
                    })
                    .toList() ??
                [];

            final template = MealTemplate()
              ..id = item['id'] as int
              ..name = item['name'] as String
              ..mealLabel = item['mealLabel'] as String?
              ..ingredients = templateIngredients
              ..createdAt = DateTime.parse(item['createdAt'] as String)
              ..updatedAt = DateTime.parse(item['updatedAt'] as String);
            await db.saveMealTemplate(template);
          } catch (e) {
            continue;
          }
        }
      }

      return ImportResult(
        success: true,
        message:
            'Restored $ingredientsAdded ingredients, $mealsAdded meals, $wellnessEntriesAdded wellness entries',
        ingredientsAdded: ingredientsAdded,
        mealsAdded: mealsAdded,
        wellnessEntriesAdded: wellnessEntriesAdded,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Replace import failed: $e',
        ingredientsAdded: 0,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    }
  }

  /// Merge mode: add new data and update existing entries
  static Future<ImportResult> _importMerge(
    AppDatabase db,
    Map<String, dynamic> payload,
    int payloadVersion,
  ) async {
    int ingredientsAdded = 0;
    int mealsAdded = 0;
    int wellnessEntriesAdded = 0;

    try {
      // Merge custom ingredients
      if (payload['customIngredients'] is List) {
        final ingredients = payload['customIngredients'] as List;
        for (final item in ingredients) {
          try {
            final existing = await db.findIngredientById(item['id'] as int);

            // Only add if not already present
            if (existing == null) {
              final ingredient = Ingredient()
                ..id = item['id'] as int
                ..name = item['name'] as String
                ..nameLower = (item['name'] as String).toLowerCase()
                ..category = FoodCategory.values.firstWhere(
                  (e) => e.name == item['category'],
                  orElse: () => FoodCategory.other,
                )
                ..fodmapLevel = item['fodmapLevel'] as String? ?? 'moderate'
                ..notes = item['notes'] as String?
                ..createdAt = DateTime.parse(item['createdAt'] as String)
                ..isSeeded = false;
              await db.saveIngredient(ingredient);
              ingredientsAdded++;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Merge meal entries
      if (payload['mealEntries'] is List) {
        final meals = payload['mealEntries'] as List;
        for (final item in meals) {
          try {
            final existing = await db.findMealById(item['id'] as int);

            // Only add if not already present
            if (existing == null) {
              final mealIngredients = (item['ingredients'] as List?)
                      ?.map((i) {
                        final mi = MealIngredient()
                          ..ingredientId = i['ingredientId'] as int
                          ..ingredientName = i['ingredientName'] as String
                          ..quantity = i['quantity'] as String?;
                        return mi;
                      })
                      .toList() ??
                  [];

              final meal = MealEntry()
                ..id = item['id'] as int
                ..consumedAt = DateTime.parse(item['consumedAt'] as String)
                ..mealLabel = item['mealLabel'] as String?
                ..ingredients = mealIngredients
                ..notes = item['notes'] as String?
                ..createdAt = DateTime.parse(item['createdAt'] as String);
              await db.saveMeal(meal);
              mealsAdded++;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Merge wellness entries
      if (payload['wellnessEntries'] is List) {
        final wellness = payload['wellnessEntries'] as List;
        // Get all existing wellness entries to check for duplicates
        final existing = await db.allWellness();
        final existingIds = existing.map((e) => e.id).toSet();

        for (final item in wellness) {
          try {
            final id = item['id'] as int;
            // Only add if not already present
            if (!existingIds.contains(id)) {
              final linkedMealIds = (item['linkedMealIds'] as List?)
                      ?.cast<int>()
                      .toList() ??
                  [];

              final rawGutPeace =
                  item['gutPeace'] as int? ?? (payloadVersion >= 2 ? 0 : 5);
              final migratedGutPeace =
                  _migrateGutPeace(rawGutPeace, payloadVersion);
              final entry = WellnessEntry()
                ..id = id
                ..recordedAt = DateTime.parse(item['recordedAt'] as String)
                ..gutPeace = migratedGutPeace
                ..heartburn = item['heartburn'] as int? ?? 1
                ..diarrhea = item['diarrhea'] as bool? ?? false
                ..wellnessScore = _wellnessScoreFor(migratedGutPeace)
                ..linkedMealIds = linkedMealIds
                ..notes = item['notes'] as String?
                ..createdAt = DateTime.parse(item['createdAt'] as String);
              await db.saveWellness(entry);
              wellnessEntriesAdded++;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Merge meal templates
      if (payload['mealTemplates'] is List) {
        final templates = payload['mealTemplates'] as List;
        final existingTemplates = await db.allMealTemplates();
        final existingTemplateIds =
            existingTemplates.map((t) => t.id).toSet();

        for (final item in templates) {
          try {
            final id = item['id'] as int;
            if (!existingTemplateIds.contains(id)) {
              final templateIngredients = (item['ingredients'] as List?)
                      ?.map((i) {
                        final mi = MealIngredient()
                          ..ingredientId = i['ingredientId'] as int
                          ..ingredientName = i['ingredientName'] as String
                          ..quantity = i['quantity'] as String?;
                        return mi;
                      })
                      .toList() ??
                  [];

              final template = MealTemplate()
                ..id = id
                ..name = item['name'] as String
                ..mealLabel = item['mealLabel'] as String?
                ..ingredients = templateIngredients
                ..createdAt = DateTime.parse(item['createdAt'] as String)
                ..updatedAt = DateTime.parse(item['updatedAt'] as String);
              await db.saveMealTemplate(template);
            }
          } catch (e) {
            continue;
          }
        }
      }

      return ImportResult(
        success: true,
        message:
            'Added $ingredientsAdded ingredients, $mealsAdded meals, $wellnessEntriesAdded wellness entries',
        ingredientsAdded: ingredientsAdded,
        mealsAdded: mealsAdded,
        wellnessEntriesAdded: wellnessEntriesAdded,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Merge import failed: $e',
        ingredientsAdded: 0,
        mealsAdded: 0,
        wellnessEntriesAdded: 0,
      );
    }
  }
}
