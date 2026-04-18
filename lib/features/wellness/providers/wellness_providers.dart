import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../../insights/domain/correlation_engine.dart';
import '../data/models/wellness_entry.dart';

// ── Draft state ──────────────────────────────────────────────────────────────

/// All slider values use 2× half-step encoding: stored 0-20 int = display
/// 0.0-10.0 in 0.5 steps. The draft state stores display doubles; conversion
/// to storage ints happens at submit time.
class WellnessDraftState {
  final double gutPeace; // display 0.0-10.0
  final double heartburn; // display 0.0-10.0
  final double stress; // display 0.0-10.0
  final int bloating; // 3-level ordinal (0=Keine, 1=Leicht, 2=Stark)
  final bool diarrhea;
  final String? notes;
  final List<int> linkedMealIds;

  const WellnessDraftState({
    this.gutPeace = 0, // 0 = no discomfort
    this.heartburn = 0, // 0 = no heartburn
    this.stress = 0, // 0 = no stress
    this.bloating = 0, // 0 = Keine
    this.diarrhea = false,
    this.notes,
    this.linkedMealIds = const [],
  });

  WellnessDraftState copyWith({
    double? gutPeace,
    double? heartburn,
    double? stress,
    int? bloating,
    bool? diarrhea,
    String? notes,
    List<int>? linkedMealIds,
  }) {
    return WellnessDraftState(
      gutPeace: gutPeace ?? this.gutPeace,
      heartburn: heartburn ?? this.heartburn,
      stress: stress ?? this.stress,
      bloating: bloating ?? this.bloating,
      diarrhea: diarrhea ?? this.diarrhea,
      notes: notes ?? this.notes,
      linkedMealIds: linkedMealIds ?? this.linkedMealIds,
    );
  }

  /// Convert display double (0.0-10.0) → storage int (0-20).
  static int toStored(double v) => (v * 2).round().clamp(0, 20);

  double get liveScore =>
      CorrelationEngine.computeWellnessScore(gutPeace: toStored(gutPeace));
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class WellnessDraftNotifier extends StateNotifier<WellnessDraftState> {
  final Ref _ref;

  WellnessDraftNotifier(this._ref) : super(const WellnessDraftState());

  void setGutPeace(double v) => state = state.copyWith(gutPeace: v);
  void setHeartburn(double v) => state = state.copyWith(heartburn: v);
  void setStress(double v) => state = state.copyWith(stress: v);
  void setBloating(int v) => state = state.copyWith(bloating: v.clamp(0, 2));
  void setDiarrhea(bool v) => state = state.copyWith(diarrhea: v);
  void setNotes(String n) => state = state.copyWith(notes: n);

  void toggleMealLink(int id) {
    final ids = List<int>.from(state.linkedMealIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    state = state.copyWith(linkedMealIds: ids);
  }

  void reset() => state = const WellnessDraftState();

  Future<void> submit() async {
    final draft = state;
    final db = await _ref.read(appDatabaseProvider.future);

    final entry = WellnessEntry()
      ..recordedAt = DateTime.now()
      ..gutPeace = WellnessDraftState.toStored(draft.gutPeace)
      ..heartburn = WellnessDraftState.toStored(draft.heartburn)
      ..stressLevel = WellnessDraftState.toStored(draft.stress)
      ..bloating = draft.bloating.clamp(0, 2)
      ..diarrhea = draft.diarrhea
      ..wellnessScore = draft.liveScore
      ..linkedMealIds = List<int>.from(draft.linkedMealIds)
      ..notes = draft.notes;

    await db.saveWellness(entry);
    reset();
    _ref.invalidate(wellnessHistoryProvider);
  }
}

final wellnessDraftProvider =
    StateNotifierProvider<WellnessDraftNotifier, WellnessDraftState>(
      (ref) => WellnessDraftNotifier(ref),
    );

// ── History ──────────────────────────────────────────────────────────────────

final wellnessHistoryProvider = FutureProvider.autoDispose
    .family<List<WellnessEntry>, _DateRangeArg>((ref, arg) async {
      final db = await ref.watch(appDatabaseProvider.future);
      return db.wellnessInRange(from: arg.from, to: arg.to);
    });

/// All wellness entries for the last year, newest first.
final wellnessAllHistoryProvider =
    FutureProvider.autoDispose<List<WellnessEntry>>((ref) async {
      final db = await ref.watch(appDatabaseProvider.future);
      final now = DateTime.now();
      final from = DateTime(now.year - 1, now.month, now.day);
      final to = DateTime(now.year, now.month, now.day + 1);
      final entries = await db.wellnessInRange(from: from, to: to);
      return entries.reversed.toList();
    });

// ── History edit/delete notifier ─────────────────────────────────────────────

class WellnessHistoryNotifier extends StateNotifier<void> {
  final Ref _ref;
  WellnessHistoryNotifier(this._ref) : super(null);

  Future<void> deleteEntry(int id) async {
    final db = await _ref.read(appDatabaseProvider.future);
    await db.deleteWellness(id);
  }
}

final wellnessHistoryNotifierProvider =
    StateNotifierProvider<WellnessHistoryNotifier, void>(
      (ref) => WellnessHistoryNotifier(ref),
    );

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
