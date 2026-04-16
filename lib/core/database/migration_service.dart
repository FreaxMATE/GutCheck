import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/wellness/data/models/wellness_entry.dart';

/// One-shot data migrations to apply on app startup.
///
/// Each migration is guarded by a SharedPreferences flag so it runs exactly
/// once per install. Keep migrations idempotent and defensive — they should
/// never fail the whole app start.
class MigrationService {
  MigrationService(this._isar);

  final Isar _isar;

  static const _gutPeaceFlipKey = 'migration_gut_peace_flip_v1';

  Future<void> runAll() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_gutPeaceFlipKey) ?? false)) {
      await _flipGutPeaceSemantics();
      await prefs.setBool(_gutPeaceFlipKey, true);
    }
  }

  /// Until v1, `gutPeace` was stored as 1..10 where 10 = perfect gut comfort.
  /// From v1 onwards, `gutPeace` is stored as 0..10 where 0 = no discomfort,
  /// 10 = extreme discomfort. Existing records must be converted.
  ///
  /// Linear mapping: new = round((10 - old) * 10 / 9)
  ///   old  1 → new 10
  ///   old  5 → new  6
  ///   old 10 → new  0
  ///
  /// `wellnessScore` is also recomputed to match the new semantics.
  Future<void> _flipGutPeaceSemantics() async {
    final all = await _isar.wellnessEntrys.where().findAll();
    if (all.isEmpty) return;

    for (final entry in all) {
      final old = entry.gutPeace;
      // Defensive: if values look already-migrated (0..10 with 0 present),
      // skip. Our old scale never stored 0.
      if (old == 0) continue;

      final migrated = ((10 - old) * 10 / 9).round().clamp(0, 10);
      entry.gutPeace = migrated;
      // new wellnessScore: higher = better wellness; 0 discomfort → 100.
      entry.wellnessScore = ((10 - migrated) / 10.0) * 100.0;
    }

    await _isar.writeTxn(() async {
      await _isar.wellnessEntrys.putAll(all);
    });
  }
}
