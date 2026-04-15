import 'package:isar/isar.dart';

import '../models/meal_template.dart';

class MealTemplateRepository {
  final Isar _isar;
  MealTemplateRepository(this._isar);

  Future<List<MealTemplate>> all() async {
    final results = await _isar.mealTemplates.where().findAll();
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }

  Future<MealTemplate?> findById(int id) => _isar.mealTemplates.get(id);

  Future<void> save(MealTemplate template) async {
    await _isar.writeTxn(() => _isar.mealTemplates.put(template));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.mealTemplates.delete(id));
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() => _isar.mealTemplates.where().deleteAll());
  }
}
