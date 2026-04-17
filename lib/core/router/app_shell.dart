import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gutcheck/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = ['/home', '/log', '/wellness', '/insights'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _tabs
        .indexWhere((t) => location.startsWith(t))
        .clamp(0, 3);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_rounded),
            selectedIcon: const Icon(Icons.restaurant_rounded),
            label: l10n.navMealLog,
          ),
          NavigationDestination(
            icon: const Icon(Icons.monitor_heart_rounded),
            selectedIcon: const Icon(Icons.monitor_heart_rounded),
            label: l10n.navWellness,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_rounded),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: l10n.navInsights,
          ),
        ],
      ),
    );
  }
}
