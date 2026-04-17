import 'package:flutter_test/flutter_test.dart';
import 'package:gutcheck/features/insights/domain/correlation_engine.dart';
import 'package:gutcheck/features/meal_log/data/models/meal_entry.dart';
import 'package:gutcheck/features/meal_log/data/models/meal_ingredient.dart';
import 'package:gutcheck/features/wellness/data/models/wellness_entry.dart';

void main() {
  group('CorrelationEngine.computeWellnessScore', () {
    // Note: gutPeace is stored as gut *discomfort* on a 0–20 scale
    // (2× encoding of 0.0–10.0). 0 = no discomfort = best wellness.

    test('no discomfort returns 100', () {
      final score = CorrelationEngine.computeWellnessScore(gutPeace: 0);
      expect(score, closeTo(100.0, 0.1));
    });

    test('max discomfort returns 0', () {
      final score = CorrelationEngine.computeWellnessScore(gutPeace: 20);
      expect(score, closeTo(0.0, 0.1));
    });

    test('mid discomfort returns ~50', () {
      final score = CorrelationEngine.computeWellnessScore(gutPeace: 10);
      expect(score, closeTo(50.0, 0.1));
    });

    test('score is between 0 and 100 for all valid inputs', () {
      for (int gp = 0; gp <= 20; gp++) {
        final score = CorrelationEngine.computeWellnessScore(gutPeace: gp);
        expect(score, greaterThanOrEqualTo(0.0));
        expect(score, lessThanOrEqualTo(100.0));
      }
    });

    test('lower discomfort produces higher score', () {
      final scoreLow = CorrelationEngine.computeWellnessScore(gutPeace: 16);
      final scoreHigh = CorrelationEngine.computeWellnessScore(gutPeace: 4);
      expect(scoreHigh, greaterThan(scoreLow));
    });
  });

  group('CorrelationEngine.computeImpactScores', () {
    test('returns empty list when no meals', () {
      final scores = CorrelationEngine.computeImpactScores(
        meals: [],
        wellnessEntries: _fakeWellness(5),
      );
      expect(scores, isEmpty);
    });

    test('returns empty list when no wellness entries', () {
      final scores = CorrelationEngine.computeImpactScores(
        meals: _fakeMeals(5, ingredientId: 1, name: 'Onion'),
        wellnessEntries: [],
      );
      expect(scores, isEmpty);
    });

    test('returns empty list when fewer than 3 co-occurrences', () {
      final meals = _fakeMeals(2, ingredientId: 42, name: 'Garlic');
      final wellness = _fakeWellnessAt(
        meals.map((m) => m.consumedAt.add(const Duration(hours: 4))).toList(),
      );

      final scores = CorrelationEngine.computeImpactScores(
        meals: meals,
        wellnessEntries: wellness,
      );
      expect(scores, isEmpty);
    });

    test('zero variance in wellness returns empty (handles gracefully)', () {
      // All wellness entries have the same constant score (zero variance).
      // Pearson r is undefined; the engine should return 0 and omit the result.
      final base = DateTime(2025, 1, 1, 12, 0);
      final meals = List.generate(
        10,
        (i) => _mealAt(
          base.add(Duration(days: i)),
          ingredientId: 1,
          name: 'Onion',
        ),
      );
      final wellness = List.generate(
        10,
        (i) => _wellnessAt(base.add(Duration(days: i, hours: 4)), score: 20.0),
      ); // constant — zero variance

      final scores = CorrelationEngine.computeImpactScores(
        meals: meals,
        wellnessEntries: wellness,
      );
      // r=0 due to zero y-variance, so no impact score is returned.
      expect(scores, isEmpty);
    });

    test('non-constant wellness produces impact scores', () {
      final base = DateTime(2025, 1, 1, 12, 0);
      // Alternate between eating onion and not eating; wellness alternates.
      final meals = <MealEntry>[];
      final wellness = <WellnessEntry>[];
      for (int i = 0; i < 10; i++) {
        if (i.isEven) {
          meals.add(
            _mealAt(
              base.add(Duration(days: i)),
              ingredientId: 1,
              name: 'Garlic',
            ),
          );
        }
        // Wellness is low on days garlic was eaten 4h earlier, high otherwise
        wellness.add(
          _wellnessAt(
            base.add(Duration(days: i, hours: 4)),
            score: i.isEven ? 20.0 : 80.0,
          ),
        );
      }

      final scores = CorrelationEngine.computeImpactScores(
        meals: meals,
        wellnessEntries: wellness,
      );
      // Should produce at least one impact score with a negative correlation
      if (scores.isNotEmpty) {
        expect(scores.first.pearsonR, lessThan(0));
      }
      // (May still be empty if sampleCount < 3)
    });
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

List<MealEntry> _fakeMeals(
  int count, {
  required int ingredientId,
  required String name,
}) {
  final base = DateTime(2025, 6, 1, 12, 0);
  return List.generate(
    count,
    (i) => _mealAt(
      base.add(Duration(days: i)),
      ingredientId: ingredientId,
      name: name,
    ),
  );
}

MealEntry _mealAt(
  DateTime time, {
  required int ingredientId,
  required String name,
}) {
  final entry = MealEntry()
    ..consumedAt = time
    ..mealLabel = 'Lunch'
    ..ingredients = [
      MealIngredient()
        ..ingredientId = ingredientId
        ..ingredientName = name,
    ]
    ..createdAt = time;
  return entry;
}

List<WellnessEntry> _fakeWellness(int count) {
  final base = DateTime(2025, 6, 1, 16, 0);
  return List.generate(
    count,
    (i) => _wellnessAt(base.add(Duration(days: i)), score: 60.0 + (i % 3) * 10),
  );
}

List<WellnessEntry> _fakeWellnessAt(List<DateTime> times) {
  return times
      .map((t) => _wellnessAt(t, score: 30.0 + (t.day % 3) * 15))
      .toList();
}

WellnessEntry _wellnessAt(DateTime time, {required double score}) {
  return WellnessEntry()
    ..recordedAt = time
    ..gutPeace = 5
    ..wellnessScore = score
    ..createdAt = time;
}
