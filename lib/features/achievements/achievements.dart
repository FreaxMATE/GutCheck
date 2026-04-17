import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database_provider.dart';

/// An achievement the user can unlock. Pure value type.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Catalog of all achievements the app tracks. Ids are stable strings used
/// as SharedPreferences keys; never rename an id.
class Achievements {
  Achievements._();

  static const firstMeal = Achievement(
    id: 'first_meal',
    title: 'First bite',
    description: 'You logged your first meal.',
    icon: Icons.restaurant_rounded,
    color: Colors.orange,
  );

  static const firstWellness = Achievement(
    id: 'first_wellness',
    title: 'Tuning in',
    description: 'First wellness check-in. Self-awareness, unlocked.',
    icon: Icons.favorite_rounded,
    color: Colors.red,
  );

  static const tenMeals = Achievement(
    id: 'ten_meals',
    title: 'Getting the hang of it',
    description: '10 meals logged. You know the drill.',
    icon: Icons.local_dining_rounded,
    color: Colors.deepOrange,
  );

  static const fiftyMeals = Achievement(
    id: 'fifty_meals',
    title: 'Meal connoisseur',
    description: '50 meals. That\'s real data.',
    icon: Icons.emoji_food_beverage_rounded,
    color: Colors.purple,
  );

  static const weekStreak = Achievement(
    id: 'streak_7',
    title: 'Week-long warrior',
    description: '7 days of consecutive logging. 🔥',
    icon: Icons.local_fire_department_rounded,
    color: Colors.red,
  );

  static const monthStreak = Achievement(
    id: 'streak_30',
    title: 'Monthly master',
    description: '30-day streak. Iron gut, iron will.',
    icon: Icons.whatshot_rounded,
    color: Colors.deepOrange,
  );

  static const customFood = Achievement(
    id: 'custom_food',
    title: 'Cookbook curator',
    description: 'Added your first custom food.',
    icon: Icons.edit_note_rounded,
    color: Colors.teal,
  );

  static const tenCustomFoods = Achievement(
    id: 'custom_food_10',
    title: 'Flavor archivist',
    description: '10 custom foods. Your pantry is your own.',
    icon: Icons.menu_book_rounded,
    color: Colors.indigo,
  );

  static const mealTemplate = Achievement(
    id: 'template_first',
    title: 'Power user',
    description: 'Saved your first meal template.',
    icon: Icons.bookmark_rounded,
    color: Colors.blue,
  );

  static const insightFound = Achievement(
    id: 'insight_80',
    title: 'Gut detective 🔍',
    description: 'Found a >80% correlation. Case cracked.',
    icon: Icons.psychology_rounded,
    color: Colors.amber,
  );

  /// All achievements, in display order.
  static const all = <Achievement>[
    firstMeal,
    firstWellness,
    tenMeals,
    fiftyMeals,
    weekStreak,
    monthStreak,
    customFood,
    tenCustomFoods,
    mealTemplate,
    insightFound,
  ];

  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}

// ── Storage ──────────────────────────────────────────────────────────────────

/// Set of achievement ids that have been unlocked.
class UnlockedAchievementsNotifier extends StateNotifier<Set<String>> {
  static const _key = 'unlocked_achievements';

  UnlockedAchievementsNotifier() : super(<String>{}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const [];
    state = list.toSet();
  }

  Future<bool> unlock(String id) async {
    if (state.contains(id)) return false;
    state = {...state, id};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
    return true;
  }
}

final unlockedAchievementsProvider =
    StateNotifierProvider<UnlockedAchievementsNotifier, Set<String>>(
      (ref) => UnlockedAchievementsNotifier(),
    );

// ── Evaluator ────────────────────────────────────────────────────────────────

/// Checks all achievement conditions against current DB state and unlocks
/// any that now qualify. Returns the list of newly unlocked achievements.
Future<List<Achievement>> evaluateAchievements(WidgetRef ref) async {
  final db = await ref.read(appDatabaseProvider.future);
  final notifier = ref.read(unlockedAchievementsProvider.notifier);
  final already = ref.read(unlockedAchievementsProvider);

  final meals = await db.allMeals();
  final wellness = await db.allWellness();
  final customIngredients = await db.allCustomIngredients();
  final templates = await db.allMealTemplates();

  final newly = <Achievement>[];

  Future<void> tryUnlock(Achievement a, bool cond) async {
    if (cond && !already.contains(a.id)) {
      final did = await notifier.unlock(a.id);
      if (did) newly.add(a);
    }
  }

  await tryUnlock(Achievements.firstMeal, meals.isNotEmpty);
  await tryUnlock(Achievements.firstWellness, wellness.isNotEmpty);
  await tryUnlock(Achievements.tenMeals, meals.length >= 10);
  await tryUnlock(Achievements.fiftyMeals, meals.length >= 50);
  await tryUnlock(Achievements.customFood, customIngredients.isNotEmpty);
  await tryUnlock(Achievements.tenCustomFoods, customIngredients.length >= 10);
  await tryUnlock(Achievements.mealTemplate, templates.isNotEmpty);

  // Streak check: count unique days with any log in the last 30 days.
  final now = DateTime.now();
  final days = <DateTime>{};
  for (final m in meals) {
    days.add(DateTime(m.consumedAt.year, m.consumedAt.month, m.consumedAt.day));
  }
  for (final w in wellness) {
    days.add(DateTime(w.recordedAt.year, w.recordedAt.month, w.recordedAt.day));
  }

  int streak = 0;
  for (int i = 0; i < 90; i++) {
    final check = DateTime(now.year, now.month, now.day - i);
    if (days.contains(check)) {
      streak++;
    } else if (i > 0) {
      break;
    }
  }

  await tryUnlock(Achievements.weekStreak, streak >= 7);
  await tryUnlock(Achievements.monthStreak, streak >= 30);

  return newly;
}

/// Toast-style overlay showing an unlocked achievement.
void showAchievementToast(BuildContext context, Achievement a) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(builder: (_) => _AchievementToast(achievement: a));
  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 3200)).then((_) {
    entry.remove();
  });
}

class _AchievementToast extends StatefulWidget {
  final Achievement achievement;
  const _AchievementToast({required this.achievement});

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePad = MediaQuery.of(context).padding;
    return Positioned(
      top: safePad.top + 12,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (ctx, _) {
            final slideIn = const Interval(
              0.0,
              0.15,
              curve: Curves.easeOutBack,
            ).transform(_c.value);
            final slideOut = const Interval(
              0.85,
              1.0,
              curve: Curves.easeIn,
            ).transform(_c.value);
            final offset = Offset(0, (1 - slideIn) * -1.0 + slideOut * -0.2);
            final opacity = (slideIn * (1 - slideOut)).clamp(0.0, 1.0);
            return FractionalTranslation(
              translation: offset,
              child: Opacity(
                opacity: opacity,
                child: _AchievementCard(achievement: widget.achievement),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(14),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: achievement.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(achievement.icon, color: achievement.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🏆  ${achievement.title}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    achievement.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trophy case screen ───────────────────────────────────────────────────────

class TrophyCaseScreen extends ConsumerWidget {
  const TrophyCaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedAchievementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trophies')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Achievements.all.length,
        itemBuilder: (ctx, i) {
          final a = Achievements.all[i];
          final isUnlocked = unlocked.contains(a.id);
          final theme = Theme.of(ctx);
          return Opacity(
            opacity: isUnlocked ? 1.0 : 0.32,
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: a.color.withValues(alpha: 0.15),
                  child: Icon(a.icon, color: a.color),
                ),
                title: Text(
                  a.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(a.description),
                trailing: isUnlocked
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.lock_outline, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
