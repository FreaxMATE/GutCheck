import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database_provider.dart';
import '../../insights/domain/correlation_engine.dart';
import '../data/models/wellness_entry.dart';

// ── Draft state ──────────────────────────────────────────────────────────────

class WellnessDraftState {
  final int gutPeace;
  final int heartburn;
  final bool diarrhea;
  final String? notes;
  final List<int> linkedMealIds;

  const WellnessDraftState({
    this.gutPeace = 10,
    this.heartburn = 1,
    this.diarrhea = false,
    this.notes,
    this.linkedMealIds = const [],
  });

  WellnessDraftState copyWith({
    int? gutPeace,
    int? heartburn,
    bool? diarrhea,
    String? notes,
    List<int>? linkedMealIds,
  }) {
    return WellnessDraftState(
      gutPeace: gutPeace ?? this.gutPeace,
      heartburn: heartburn ?? this.heartburn,
      diarrhea: diarrhea ?? this.diarrhea,
      notes: notes ?? this.notes,
      linkedMealIds: linkedMealIds ?? this.linkedMealIds,
    );
  }

  double get liveScore => CorrelationEngine.computeWellnessScore(
        gutPeace: gutPeace,
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class WellnessDraftNotifier extends StateNotifier<WellnessDraftState> {
  final Ref _ref;

  WellnessDraftNotifier(this._ref) : super(const WellnessDraftState());

  void setGutPeace(int v) => state = state.copyWith(gutPeace: v);
  void setHeartburn(int v) => state = state.copyWith(heartburn: v);
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
      ..gutPeace = draft.gutPeace
      ..heartburn = draft.heartburn
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

final wellnessHistoryProvider =
    FutureProvider.autoDispose.family<List<WellnessEntry>, _DateRangeArg>(
  (ref, arg) async {
    final db = await ref.watch(appDatabaseProvider.future);
    return db.wellnessInRange(from: arg.from, to: arg.to);
  },
);

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
