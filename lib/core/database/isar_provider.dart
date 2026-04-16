import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/models/meal_template.dart';
import '../../features/pantry/data/models/ingredient.dart';
import '../../features/wellness/data/models/wellness_entry.dart';
import 'migration_service.dart';
import 'seed_service.dart';

/// Singleton Isar database. keepAlive ensures it's never disposed.
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    // MealIngredient is @embedded so it doesn't need a separate schema entry.
    [IngredientSchema, MealEntrySchema, MealTemplateSchema, WellnessEntrySchema],
    directory: dir.path,
  );

  // Run pending data migrations (idempotent, guarded by prefs flags).
  await MigrationService(isar).runAll();

  // Seed the ingredient database on first launch.
  await SeedService(isar).seedIfNeeded();

  // Keep alive so the database is never closed automatically.
  ref.keepAlive();

  return isar;
});
