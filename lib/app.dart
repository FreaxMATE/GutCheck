import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/palette_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/home/providers/home_providers.dart';
import 'l10n/app_localizations.dart';

/// Latches the last successful wellness avg so the theme seed doesn't flip
/// back to the base color while [weeklyWellnessAvgProvider] is reloading
/// (which would cause two AppBar/theme transitions per pull-to-refresh).
final _stableWellnessAvgProvider = StateProvider<double?>((ref) => null);

class GutCheckApp extends ConsumerWidget {
  const GutCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Adaptive theme tint: if the user's weekly wellness avg is low, shift
    // the seed color toward a calming blue-green. We watch a latched copy so
    // the theme only updates when new data arrives, not on the loading gap.
    ref.listen(weeklyWellnessAvgProvider, (_, next) {
      next.whenData((v) {
        if (v != ref.read(_stableWellnessAvgProvider)) {
          ref.read(_stableWellnessAvgProvider.notifier).state = v;
        }
      });
    });
    final wellnessForTheme = ref.watch(_stableWellnessAvgProvider);
    final palette = ref.watch(paletteProvider);
    final seed = AppTheme.resolveSeed(palette, wellnessForTheme);
    return MaterialApp.router(
      title: 'GutCheck',
      theme: AppTheme.light(palette: palette, seedColor: seed),
      darkTheme: AppTheme.dark(palette: palette, seedColor: seed),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
