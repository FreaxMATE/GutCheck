import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/ui/screens/home_screen.dart';
import '../../features/insights/ui/screens/insights_screen.dart';
import '../../features/insights/ui/screens/insights_detail_screens.dart';
import '../../features/insights/ui/screens/insights_trend_screen.dart';
import '../../features/meal_log/ui/screens/meal_log_screen.dart';
import '../../features/pantry/ui/screens/add_custom_food_screen.dart';
import '../../features/pantry/ui/screens/pantry_screen.dart';
import '../../features/wellness/ui/screens/wellness_check_screen.dart';
import '../../features/wellness/ui/screens/wellness_history_screen.dart';
import '../animations/animations.dart';
import 'app_shell.dart';
import 'dev_screen.dart';
import 'settings_screen.dart';

/// Fade-through transition for pushed sub-routes. Becomes instant when
/// animations are disabled.
Page<T> _fadeThroughPage<T>(Widget child) {
  final enabled = animationsEnabledListenable.value;
  return CustomTransitionPage<T>(
    child: child,
    transitionDuration: enabled
        ? const Duration(milliseconds: 260)
        : Duration.zero,
    reverseTransitionDuration: enabled
        ? const Duration(milliseconds: 200)
        : Duration.zero,
    transitionsBuilder: (_, anim, __, child) {
      if (!enabled) return child;
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      if (state.uri.path == '/' || state.uri.path.isEmpty) return '/home';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (c, s) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/log',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: MealLogScreen()),
          ),
          GoRoute(
            path: '/wellness',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WellnessCheckScreen()),
            routes: [
              GoRoute(
                path: 'history',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const WellnessHistoryScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: InsightsScreen()),
            routes: [
              GoRoute(
                path: 'calendar',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const InsightsCalendarScreen()),
              ),
              GoRoute(
                path: 'heatmap',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const InsightsHeatmapScreen()),
              ),
              GoRoute(
                path: 'impact',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const InsightsImpactScreen()),
              ),
              GoRoute(
                path: 'fingerprint',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const InsightsFingerprintScreen()),
              ),
              GoRoute(
                path: 'scatter',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const InsightsScatterScreen()),
              ),
              GoRoute(
                path: 'trend',
                pageBuilder: (c, s) =>
                    _fadeThroughPage(const InsightsTrendScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/pantry',
        pageBuilder: (c, s) => _fadeThroughPage(const PantryScreen()),
        routes: [
          GoRoute(
            path: 'add-food',
            pageBuilder: (c, s) =>
                _fadeThroughPage(const AddCustomFoodScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (c, s) => _fadeThroughPage(const SettingsScreen()),
      ),
      GoRoute(
        path: '/dev',
        pageBuilder: (c, s) => _fadeThroughPage(const DevScreen()),
      ),
    ],
  );
});
