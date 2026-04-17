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
  static const _halfStepKey = 'migration_halfstep_v1';

  Future<void> runAll() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_gutPeaceFlipKey) ?? false)) {
      await _flipGutPeaceSemantics();
      await prefs.setBool(_gutPeaceFlipKey, true);
    }

    if (!(prefs.getBool(_halfStepKey) ?? false)) {
      await _convertToHalfStepEncoding();
      await prefs.setBool(_halfStepKey, true);
    }
  }

  /// v1 migration: flip gutPeace from "peace" (1-10 higher=better) to
  /// "discomfort" (0-10 higher=worse).
  Future<void> _flipGutPeaceSemantics() async {
    final all = await _isar.wellnessEntrys.where().findAll();
    if (all.isEmpty) return;

    for (final entry in all) {
      final old = entry.gutPeace;
      if (old == 0) continue;
      final migrated = ((10 - old) * 10 / 9).round().clamp(0, 10);
      entry.gutPeace = migrated;
      entry.wellnessScore = ((10 - migrated) / 10.0) * 100.0;
    }

    await _isar.writeTxn(() async {
      await _isar.wellnessEntrys.putAll(all);
    });
  }

  /// v2 migration: convert all slider values from whole-number 0-10 / 1-10
  /// to the 2× half-step encoding (0-20 = 0.0-10.0 in 0.5 steps).
  ///
  /// - gutPeace: was 0-10, now 0-20 → multiply by 2
  /// - heartburn: was 1-10 (higher=worse), now 0-20 (0-10 range) →
  ///   shift to 0-based then multiply: (old - 1) * 2
  /// - stressLevel: new field, already defaults to 0, no migration needed
  ///
  /// Also recomputes wellnessScore for the new encoding.
  Future<void> _convertToHalfStepEncoding() async {
    final all = await _isar.wellnessEntrys.where().findAll();
    if (all.isEmpty) return;

    for (final entry in all) {
      // Guard: if values are already > 10, this migration already ran
      // (or data is corrupt). Skip.
      if (entry.gutPeace > 10 || entry.heartburn > 10) continue;

      entry.gutPeace = (entry.gutPeace.clamp(0, 10)) * 2;
      // Heartburn shifts from 1-10 to 0-10 then doubles.
      final hb = entry.heartburn.clamp(0, 10);
      entry.heartburn = (hb <= 1 ? 0 : (hb - 1)) * 2;

      // Recompute wellness score with new encoding.
      entry.wellnessScore = ((20 - entry.gutPeace) / 20.0) * 100.0;
    }

    await _isar.writeTxn(() async {
      await _isar.wellnessEntrys.putAll(all);
    });
  }
}
