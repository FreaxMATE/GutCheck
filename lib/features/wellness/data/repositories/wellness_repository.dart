import 'package:isar/isar.dart';

import '../models/wellness_entry.dart';

class WellnessRepository {
  final Isar _isar;
  WellnessRepository(this._isar);

  Future<List<WellnessEntry>> inRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final results = await _isar.wellnessEntrys
        .filter()
        .recordedAtBetween(from, to)
        .findAll();
    results.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return results;
  }

  Future<List<WellnessEntry>> forDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final results = await _isar.wellnessEntrys
        .filter()
        .recordedAtBetween(start, end)
        .findAll();
    results.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return results;
  }

  Future<void> save(WellnessEntry entry) async {
    await _isar.writeTxn(() => _isar.wellnessEntrys.put(entry));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.wellnessEntrys.delete(id));
  }

  Future<List<WellnessEntry>> all() async {
    final results = await _isar.wellnessEntrys.where().findAll();
    results.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return results;
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() => _isar.wellnessEntrys.where().deleteAll());
  }
}
