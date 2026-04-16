import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database_provider.dart';
import 'export_delivery.dart';

export 'import_service.dart';

class ExportService {
  ExportService._();

  static Future<void> exportAll(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);

    final ingredients = await db.allCustomIngredients();
    final meals = await db.allMeals();
    final wellness = await db.allWellness();
    final templates = await db.allMealTemplates();

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      // Bumped to 2 when gutPeace semantics flipped:
      //   v1: 1-10, higher = better (gut peace)
      //   v2: 0-10, higher = worse (gut discomfort)
      // Importers for v < 2 must convert gutPeace values.
      'version': 2,
      'customIngredients': ingredients.map((i) => {
        'id': i.id,
        'name': i.name,
        'category': i.category.name,
        'fodmapLevel': i.fodmapLevel,
        'notes': i.notes,
        'createdAt': i.createdAt.toIso8601String(),
      }).toList(),
      'mealEntries': meals.map((m) => {
        'id': m.id,
        'consumedAt': m.consumedAt.toIso8601String(),
        'mealLabel': m.mealLabel,
        'ingredients': m.ingredients.map((i) => {
          'ingredientId': i.ingredientId,
          'ingredientName': i.ingredientName,
          'quantity': i.quantity,
        }).toList(),
        'notes': m.notes,
        'createdAt': m.createdAt.toIso8601String(),
      }).toList(),
      'wellnessEntries': wellness.map((w) => {
        'id': w.id,
        'recordedAt': w.recordedAt.toIso8601String(),
        'gutPeace': w.gutPeace,
        'heartburn': w.heartburn,
        'diarrhea': w.diarrhea,
        'wellnessScore': w.wellnessScore,
        'linkedMealIds': w.linkedMealIds,
        'notes': w.notes,
        'createdAt': w.createdAt.toIso8601String(),
      }).toList(),
      'mealTemplates': templates.map((t) => {
        'id': t.id,
        'name': t.name,
        'mealLabel': t.mealLabel,
        'ingredients': t.ingredients.map((i) => {
          'ingredientId': i.ingredientId,
          'ingredientName': i.ingredientName,
          'quantity': i.quantity,
        }).toList(),
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      }).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(payload);
    final result = await deliverExport(json);
    if (result.showMessage) {
      throw ExportResult(
        success: true,
        filePath: result.message,
        message: result.message,
      );
    }
  }

  static Future<void> exportPantry(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);
    final ingredients = await db.allCustomIngredients();

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      // Bumped to 2 when gutPeace semantics flipped:
      //   v1: 1-10, higher = better (gut peace)
      //   v2: 0-10, higher = worse (gut discomfort)
      // Importers for v < 2 must convert gutPeace values.
      'version': 2,
      'customIngredients': ingredients.map((i) => {
        'id': i.id,
        'name': i.name,
        'category': i.category.name,
        'fodmapLevel': i.fodmapLevel,
        'notes': i.notes,
        'createdAt': i.createdAt.toIso8601String(),
      }).toList(),
      'mealEntries': [],
      'wellnessEntries': [],
    };

    final json = const JsonEncoder.withIndent('  ').convert(payload);
    final result = await deliverExport(json);
    if (result.showMessage) {
      throw ExportResult(
        success: true,
        filePath: result.message,
        message: result.message,
      );
    }
  }

  static Future<void> clearAll(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.deleteAllMeals();
    await db.deleteAllWellness();
    await db.deleteAllCustomIngredients();
    await db.deleteAllMealTemplates();
  }
}

/// Exception thrown to indicate successful export with file path info
class ExportResult implements Exception {
  final bool success;
  final String filePath;
  final String message;

  ExportResult({
    required this.success,
    required this.filePath,
    required this.message,
  });

  @override
  String toString() => message;
}
