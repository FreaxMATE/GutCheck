import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../data/models/meal_entry.dart';

// ── Today's meal log ────────────────────────────────────────────────────────

class MealLogNotifier extends AsyncNotifier<List<MealEntry>> {
  @override
  Future<List<MealEntry>> build() async {
    final db = await ref.watch(appDatabaseProvider.future);
    return db.mealsForDate(DateTime.now());
  }

  Future<void> addMeal(MealEntry entry) async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.saveMeal(entry);
    ref.invalidateSelf();
  }

  Future<void> updateMeal(MealEntry entry) async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.saveMeal(entry);
    ref.invalidateSelf();
  }

  Future<void> deleteMeal(int id) async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.deleteMeal(id);
    ref.invalidateSelf();
  }
}

final mealLogProvider = AsyncNotifierProvider<MealLogNotifier, List<MealEntry>>(
  MealLogNotifier.new,
);

// ── Recent history (last 14 days, newest first) ─────────────────────────────

/// Returns meal entries for the last 14 days, newest-day first.
final mealHistoryProvider = FutureProvider.autoDispose<List<MealEntry>>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day - 13);
  final to = DateTime(now.year, now.month, now.day + 1);
  final entries = await db.mealsInRange(from: from, to: to);
  return entries.reversed.toList();
});

// ── Range query (used by Insights) ─────────────────────────────────────────

final mealsInRangeProvider = FutureProvider.autoDispose
    .family<List<MealEntry>, _DateRangeArg>((ref, arg) async {
      final db = await ref.watch(appDatabaseProvider.future);
      return db.mealsInRange(from: arg.from, to: arg.to);
    });

class _DateRangeArg {
  final DateTime from;
  final DateTime to;
  const _DateRangeArg(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      other is _DateRangeArg && from == other.from && to == other.to;

  @override
  int get hashCode => Object.hash(from, to);
}
