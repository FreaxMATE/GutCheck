import 'dart:math';

import '../../features/meal_log/data/models/meal_entry.dart';
import '../../features/meal_log/data/models/meal_ingredient.dart';
import '../../features/pantry/data/models/ingredient.dart';
import '../../features/wellness/data/models/wellness_entry.dart';
import 'app_database.dart';

/// Inserts 30 days of realistic sample meal + wellness data.
///
/// Design:
///   Three-day cycle to produce detectable (but not unrealistically perfect)
///   correlations:
///   Day A (high-FODMAP): onion/garlic-heavy lunch → gut peace ~3 that evening
///   Day B (low-FODMAP):  salmon/rice/veg lunch   → gut peace ~8 that evening
///   Day C (moderate):    chicken/lentils lunch   → gut peace ~6 that evening
///
///   Each day has 4 meals + 4 wellness entries (morning / post-lunch / evening
///   / post-dinner).  Scores include ±2 random noise and ~15 % "off" days
///   where the expected pattern is loosely reversed, keeping Spearman r in a
///   realistic 0.45–0.75 range.
///
///   Wellness timing ensures multiple lag windows show correlations:
///     post-lunch  16:30  →  4 h lag from lunch
///     evening     19:30  →  6 h lag from lunch / 12 h lag from breakfast
///     post-dinner 21:00  →  2 h lag from dinner / 8 h lag from lunch
class SampleDataService {
  final AppDatabase _db;

  SampleDataService(this._db);

  Future<bool> hasSampleData() async {
    final count = await _db.sampleMealCount();
    return count > 0;
  }

  Future<void> insertSampleData() async {
    // Fetch required ingredients ─────────────────────────────────────────────
    final onion = await _byName('Onion');
    final garlic = await _byName('Garlic');
    final pasta = await _byName('Pasta');
    final wheatBread = await _byName('Wheat Bread');
    final cowsMilk = await _byName("Cow's Milk");
    final mushroom = await _byName('Mushroom');
    final apple = await _byName('Apple');

    final salmon = await _byName('Salmon');
    final whiteRice = await _byName('White Rice');
    final spinach = await _byName('Spinach');
    final chicken = await _byName('Chicken Breast');
    final carrot = await _byName('Carrot');
    final blueberry = await _byName('Blueberry');
    final egg = await _byName('Egg');
    final oats = await _byName('Oats');
    final brownRice = await _byName('Brown Rice');
    final zucchini = await _byName('Zucchini');
    final tomato = await _byName('Tomato');
    final quinoa = await _byName('Quinoa');
    final turkey = await _byName('Turkey');
    final avocado = await _byName('Avocado');
    final lentils = await _byName('Lentils');
    final broccoli = await _byName('Broccoli');
    final greenTea = await _byName('Green Tea');
    final blackCoffee = await _byName('Black Coffee');

    final now = DateTime.now();
    final meals = <MealEntry>[];
    final wellness = <WellnessEntry>[];

    for (int day = 29; day >= 0; day--) {
      final date = now.subtract(Duration(days: day));
      final cycleDay = day % 3;

      // Per-day seeded RNG for deterministic but varied noise.
      final rng = Random(42 + day);
      // ~15 % of days are "off" days: pattern loosens so correlations stay
      // realistic (Spearman r ~0.5–0.75 rather than 0.99).
      final isOffDay = rng.nextDouble() < 0.15;

      // ── Time anchors ──────────────────────────────────────────────────────
      // Breakfast times vary by cycle so the 12 h lag window hits different
      // wellness entries across the three cycle types.
      final breakfastTime = DateTime(
        date.year,
        date.month,
        date.day,
        cycleDay == 1 ? 7 : 8, // 07:00 / 08:00 / 08:00
        cycleDay == 0
            ? 30
            : cycleDay == 1
            ? 0
            : 15, // :30 / :00 / :15
      );
      // Lunch times differ so lag windows 4 h and 6 h each get coverage.
      final lunchTime = DateTime(
        date.year,
        date.month,
        date.day,
        cycleDay == 0 ? 12 : 13, // 12:xx / 13:xx / 13:xx
        cycleDay == 0
            ? 15
            : cycleDay == 1
            ? 0
            : 30, // :15 / :00 / :30
      );
      final snackTime = DateTime(date.year, date.month, date.day, 15, 30);
      // Dinner times vary so the 2 h post-dinner check falls in the right window.
      final dinnerTime = DateTime(
        date.year,
        date.month,
        date.day,
        cycleDay == 1 ? 18 : 19, // 19:00 / 18:xx / 19:xx
        cycleDay == 0
            ? 0
            : cycleDay == 1
            ? 30
            : 0, // :00 / :30 / :00
      );

      // Four wellness check-in times per day:
      //   09:00  morning baseline
      //   16:30  ~4 h after lunch  (captures 4 h lag)
      //   19:30  ~6–7 h after lunch (captures 6 h lag / 12 h after early breakfast)
      //   21:00  ~2 h after dinner  (captures 2 h lag / 8 h after lunch)
      final morningWellness = DateTime(date.year, date.month, date.day, 9, 0);
      final postLunchWellness = DateTime(
        date.year,
        date.month,
        date.day,
        16,
        30,
      );
      final eveningWellness = DateTime(date.year, date.month, date.day, 19, 30);
      final postDinnerWellness = DateTime(
        date.year,
        date.month,
        date.day,
        21,
        0,
      );

      if (cycleDay == 0) {
        // ─── Day A: High-FODMAP ───────────────────────────────────────────

        // Breakfast: egg + wheat bread + milk coffee
        meals.add(
          _meal(breakfastTime, 'Breakfast', [
            if (egg != null) _mi(egg, 'Egg', '2 eggs'),
            if (wheatBread != null) _mi(wheatBread, 'Wheat Bread', '2 slices'),
            if (cowsMilk != null) _mi(cowsMilk, "Cow's Milk", '200 ml'),
          ]),
        );

        // Lunch: pasta with onion & garlic sauce + mushroom
        meals.add(
          _meal(lunchTime, 'Lunch', [
            if (pasta != null) _mi(pasta, 'Pasta', '200 g'),
            if (onion != null) _mi(onion, 'Onion', '1 medium'),
            if (garlic != null) _mi(garlic, 'Garlic', '3 cloves'),
            if (mushroom != null) _mi(mushroom, 'Mushroom', 'handful'),
          ], notes: 'Had pasta with garlic-onion sauce'),
        );

        // Snack: apple
        meals.add(
          _meal(snackTime, 'Snack', [
            if (apple != null) _mi(apple, 'Apple', '1 large'),
          ]),
        );

        // Dinner: chicken + broccoli + rice
        meals.add(
          _meal(dinnerTime, 'Dinner', [
            if (chicken != null) _mi(chicken, 'Chicken Breast', '150 g'),
            if (broccoli != null) _mi(broccoli, 'Broccoli', '1 cup'),
            if (whiteRice != null) _mi(whiteRice, 'White Rice', '150 g'),
          ]),
        );

        // On off-days the high-FODMAP meal causes little trouble (tolerance
        // varies day-to-day).  Normal days show typical gut distress.
        final morning = _noisy(rng, 7, spread: 1);
        final postLunch = isOffDay
            ? _noisy(rng, 7, spread: 1)
            : _noisy(rng, 5, spread: 1);
        final evening = isOffDay
            ? _noisy(rng, 7, spread: 1)
            : _noisy(rng, 3, spread: 2);
        final postDinner = isOffDay
            ? _noisy(rng, 6, spread: 1)
            : _noisy(rng, 4, spread: 1);
        // Heartburn: garlic/onion/milk → high heartburn on normal days.
        final hbMorning = _noisy(rng, 2, spread: 1);
        final hbPostLunch = isOffDay
            ? _noisy(rng, 2, spread: 1)
            : _noisy(rng, 6, spread: 2);
        final hbEvening = isOffDay
            ? _noisy(rng, 2, spread: 1)
            : _noisy(rng, 7, spread: 2);
        final hbPostDinner = isOffDay
            ? _noisy(rng, 3, spread: 1)
            : _noisy(rng, 5, spread: 1);

        // Diarrhea: triggered by onion/garlic on non-off days, ~50% chance.
        final dPostLunch = !isOffDay && rng.nextBool();
        final dEvening = !isOffDay && rng.nextBool();
        final dPostDinner = !isOffDay && rng.nextDouble() < 0.3;

        wellness.add(
          _wellness(morningWellness, gutPeace: morning, heartburn: hbMorning),
        );
        wellness.add(
          _wellness(
            postLunchWellness,
            gutPeace: postLunch,
            heartburn: hbPostLunch,
            diarrhea: dPostLunch,
          ),
        );
        wellness.add(
          _wellness(
            eveningWellness,
            gutPeace: evening,
            heartburn: hbEvening,
            diarrhea: dEvening,
            notes: (!isOffDay && day % 6 == 0)
                ? 'Bloating and discomfort after lunch'
                : null,
          ),
        );
        wellness.add(
          _wellness(
            postDinnerWellness,
            gutPeace: postDinner,
            heartburn: hbPostDinner,
            diarrhea: dPostDinner,
          ),
        );
      } else if (cycleDay == 1) {
        // ─── Day B: Low-FODMAP / good day ────────────────────────────────

        // Breakfast: oats + blueberry + green tea
        meals.add(
          _meal(breakfastTime, 'Breakfast', [
            if (oats != null) _mi(oats, 'Oats', '60 g'),
            if (blueberry != null) _mi(blueberry, 'Blueberry', 'handful'),
            if (greenTea != null) _mi(greenTea, 'Green Tea', '300 ml'),
          ]),
        );

        // Lunch: salmon + rice + spinach + tomato
        meals.add(
          _meal(lunchTime, 'Lunch', [
            if (salmon != null) _mi(salmon, 'Salmon', '180 g'),
            if (whiteRice != null) _mi(whiteRice, 'White Rice', '150 g'),
            if (spinach != null) _mi(spinach, 'Spinach', '2 cups'),
            if (tomato != null) _mi(tomato, 'Tomato', '2 medium'),
          ]),
        );

        // Snack: carrot + avocado
        meals.add(
          _meal(snackTime, 'Snack', [
            if (carrot != null) _mi(carrot, 'Carrot', '2 medium'),
            if (avocado != null) _mi(avocado, 'Avocado', '½ avocado'),
          ]),
        );

        // Dinner: turkey + brown rice + zucchini
        meals.add(
          _meal(dinnerTime, 'Dinner', [
            if (turkey != null) _mi(turkey, 'Turkey', '150 g'),
            if (brownRice != null) _mi(brownRice, 'Brown Rice', '150 g'),
            if (zucchini != null) _mi(zucchini, 'Zucchini', '1 medium'),
          ], notes: day % 7 == 0 ? 'Felt great today!' : null),
        );

        // Off-days: something else caused mild issues despite the good diet.
        final morning = _noisy(rng, 8, spread: 1);
        final postLunch = isOffDay
            ? _noisy(rng, 4, spread: 1)
            : _noisy(rng, 8, spread: 1);
        final evening = isOffDay
            ? _noisy(rng, 4, spread: 2)
            : _noisy(rng, 8, spread: 1);
        final postDinner = isOffDay
            ? _noisy(rng, 5, spread: 1)
            : _noisy(rng, 8, spread: 1);
        // Heartburn: clean low-FODMAP day → minimal heartburn.
        final hbMorning = _noisy(rng, 1, spread: 1);
        final hbPostLunch = isOffDay
            ? _noisy(rng, 5, spread: 1)
            : _noisy(rng, 1, spread: 1);
        final hbEvening = isOffDay
            ? _noisy(rng, 4, spread: 2)
            : _noisy(rng, 2, spread: 1);
        final hbPostDinner = isOffDay
            ? _noisy(rng, 4, spread: 1)
            : _noisy(rng, 1, spread: 1);

        wellness.add(
          _wellness(morningWellness, gutPeace: morning, heartburn: hbMorning),
        );
        wellness.add(
          _wellness(
            postLunchWellness,
            gutPeace: postLunch,
            heartburn: hbPostLunch,
          ),
        );
        wellness.add(
          _wellness(
            eveningWellness,
            gutPeace: evening,
            heartburn: hbEvening,
            notes: (!isOffDay && day % 7 == 1)
                ? 'Feeling really good, no issues'
                : null,
          ),
        );
        wellness.add(
          _wellness(
            postDinnerWellness,
            gutPeace: postDinner,
            heartburn: hbPostDinner,
          ),
        );
      } else {
        // ─── Day C: Moderate / mixed day ─────────────────────────────────

        // Breakfast: egg + oats + black coffee
        meals.add(
          _meal(breakfastTime, 'Breakfast', [
            if (egg != null) _mi(egg, 'Egg', '1 egg'),
            if (oats != null) _mi(oats, 'Oats', '50 g'),
            if (blackCoffee != null) _mi(blackCoffee, 'Black Coffee', '250 ml'),
          ]),
        );

        // Lunch: chicken + lentils (moderate FODMAP) + spinach + carrot
        meals.add(
          _meal(lunchTime, 'Lunch', [
            if (chicken != null) _mi(chicken, 'Chicken Breast', '150 g'),
            if (lentils != null) _mi(lentils, 'Lentils', '120 g'),
            if (spinach != null) _mi(spinach, 'Spinach', '1 cup'),
            if (carrot != null) _mi(carrot, 'Carrot', '1 medium'),
          ]),
        );

        // Snack: blueberry
        meals.add(
          _meal(snackTime, 'Snack', [
            if (blueberry != null) _mi(blueberry, 'Blueberry', 'large handful'),
          ]),
        );

        // Dinner: salmon + quinoa + zucchini + tomato
        meals.add(
          _meal(dinnerTime, 'Dinner', [
            if (salmon != null) _mi(salmon, 'Salmon', '160 g'),
            if (quinoa != null) _mi(quinoa, 'Quinoa', '120 g'),
            if (zucchini != null) _mi(zucchini, 'Zucchini', '1 medium'),
            if (tomato != null) _mi(tomato, 'Tomato', '1 large'),
          ]),
        );

        // Moderate day: scores cluster around 6 with ±2 spread.
        final morning = _noisy(rng, 7, spread: 1);
        final postLunch = _noisy(rng, 6, spread: 2);
        final evening = _noisy(rng, 6, spread: 2);
        final postDinner = _noisy(rng, 6, spread: 1);
        // Heartburn: moderate — lentils can cause mild heartburn.
        final hbMorning = _noisy(rng, 2, spread: 1);
        final hbPostLunch = _noisy(rng, 3, spread: 1);
        final hbEvening = _noisy(rng, 4, spread: 2);
        final hbPostDinner = _noisy(rng, 3, spread: 1);

        wellness.add(
          _wellness(morningWellness, gutPeace: morning, heartburn: hbMorning),
        );
        wellness.add(
          _wellness(
            postLunchWellness,
            gutPeace: postLunch,
            heartburn: hbPostLunch,
          ),
        );
        wellness.add(
          _wellness(
            eveningWellness,
            gutPeace: evening,
            heartburn: hbEvening,
            notes: day % 9 == 2 ? 'Some mild bloating in the evening' : null,
          ),
        );
        wellness.add(
          _wellness(
            postDinnerWellness,
            gutPeace: postDinner,
            heartburn: hbPostDinner,
          ),
        );
      }
    }

    // ── Save everything ──────────────────────────────────────────────────────
    await _db.saveMeals(meals);
    final mealIds = meals.map((m) => m.id).toList();

    // Link wellness entries to the meal that most likely caused them.
    // Per-day layout (loop runs day=29 down to day=0, oldest first):
    //   meals     : [d*4+0 = breakfast, d*4+1 = lunch, d*4+2 = snack, d*4+3 = dinner]
    //   wellness  : [d*4+0 = morning,   d*4+1 = post-lunch, d*4+2 = evening, d*4+3 = post-dinner]
    const totalDays = 30;
    for (int d = 0; d < totalDays; d++) {
      final lunchIdx = d * 4 + 1;
      final dinnerIdx = d * 4 + 3;
      final postLunchWIdx = d * 4 + 1;
      final eveningWIdx = d * 4 + 2;
      final postDinnerWIdx = d * 4 + 3;

      if (lunchIdx < mealIds.length) {
        if (postLunchWIdx < wellness.length) {
          wellness[postLunchWIdx].linkedMealIds = [mealIds[lunchIdx]];
        }
        if (eveningWIdx < wellness.length) {
          wellness[eveningWIdx].linkedMealIds = [mealIds[lunchIdx]];
        }
      }
      if (dinnerIdx < mealIds.length && postDinnerWIdx < wellness.length) {
        wellness[postDinnerWIdx].linkedMealIds = [mealIds[dinnerIdx]];
      }
    }
    await _db.saveWellnessEntries(wellness);
  }

  Future<void> clearSampleData() async {
    await _db.deleteSampleMeals();
    await _db.deleteSampleWellness();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<Ingredient?> _byName(String name) => _db.findIngredientByName(name);

  MealEntry _meal(
    DateTime at,
    String label,
    List<MealIngredient> ings, {
    String? notes,
  }) => MealEntry()
    ..consumedAt = at
    ..mealLabel = label
    ..ingredients = ings
    ..notes = notes
    ..isSample = true;

  WellnessEntry _wellness(
    DateTime at, {
    required int gutPeace, // legacy: callers pass "peace" (10 = great day)
    int heartburn = 1,
    int stress = 0, // 0-10 display value
    bool diarrhea = false,
    String? notes,
  }) {
    // Convert legacy peace (1=bad, 10=good) → discomfort (0=good, 10=bad) → 2× encoding
    final peace = gutPeace.clamp(1, 10);
    final discomfort = ((10 - peace) * 10 / 9).round().clamp(0, 10);
    final storedGut = discomfort * 2; // 0-20
    final storedHb = (heartburn.clamp(1, 10) - 1) * 2; // 0-18
    final storedStress = stress.clamp(0, 10) * 2; // 0-20
    // Bloating is a 3-level ordinal (0=Keine, 1=Leicht, 2=Stark). We bucket
    // the discomfort score so there's still some correlation signal for the
    // engine: 0-2 → Keine, 3-6 → Leicht, 7-10 → Stark. A small per-day wobble
    // keeps the relationship imperfect.
    final bucketed = discomfort <= 2
        ? 0
        : discomfort <= 6
            ? 1
            : 2;
    final wobble = (at.day % 7 == 0 && bucketed > 0) ? -1 : 0;
    final storedBloat = (bucketed + wobble).clamp(0, 2);
    return WellnessEntry()
      ..recordedAt = at
      ..gutPeace = storedGut
      ..heartburn = storedHb
      ..stressLevel = storedStress
      ..bloating = storedBloat
      ..diarrhea = diarrhea
      ..wellnessScore = ((20 - storedGut) / 20.0) * 100.0
      ..linkedMealIds = []
      ..notes = notes
      ..isSample = true;
  }

  MealIngredient _mi(Ingredient ing, String name, [String? quantity]) =>
      MealIngredient()
        ..ingredientId = ing.id
        ..ingredientName = name
        ..quantity = quantity;

  /// Returns [center] clamped to 1–10 with uniform noise in ±[spread].
  static int _noisy(Random rng, int center, {int spread = 2}) =>
      (center + rng.nextInt(spread * 2 + 1) - spread).clamp(1, 10);
}
