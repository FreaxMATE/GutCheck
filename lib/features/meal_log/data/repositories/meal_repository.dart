import 'package:isar/isar.dart';

import '../models/meal_entry.dart';

class MealRepository {
  final Isar _isar;
  MealRepository(this._isar);

  Future<List<MealEntry>> forDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final results = await _isar.mealEntrys
        .filter()
        .consumedAtBetween(start, end)
        .findAll();
    results.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    return results;
  }

  Future<List<MealEntry>> inRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final results = await _isar.mealEntrys
        .filter()
        .consumedAtBetween(from, to)
        .findAll();
    results.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    return results;
  }

  Future<MealEntry?> findById(int id) => _isar.mealEntrys.get(id);

  Future<void> save(MealEntry entry) async {
    await _isar.writeTxn(() => _isar.mealEntrys.put(entry));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.mealEntrys.delete(id));
  }

  Future<List<MealEntry>> all() async {
    final results = await _isar.mealEntrys.where().findAll();
    results.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    return results;
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() => _isar.mealEntrys.where().deleteAll());
  }
}
