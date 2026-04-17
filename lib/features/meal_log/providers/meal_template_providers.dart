import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../data/models/meal_template.dart';

class MealTemplateNotifier extends AsyncNotifier<List<MealTemplate>> {
  @override
  Future<List<MealTemplate>> build() async {
    final db = await ref.watch(appDatabaseProvider.future);
    return db.allMealTemplates();
  }

  Future<void> saveTemplate(MealTemplate template) async {
    final db = await ref.read(appDatabaseProvider.future);
    template.updatedAt = DateTime.now();
    await db.saveMealTemplate(template);
    ref.invalidateSelf();
  }

  Future<void> deleteTemplate(int id) async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.deleteMealTemplate(id);
    ref.invalidateSelf();
  }
}

final mealTemplateProvider =
    AsyncNotifierProvider<MealTemplateNotifier, List<MealTemplate>>(
      MealTemplateNotifier.new,
    );
