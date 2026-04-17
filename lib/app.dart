import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/palette_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/home/providers/home_providers.dart';
import 'l10n/app_localizations.dart';

class GutCheckApp extends ConsumerWidget {
  const GutCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Adaptive theme tint: if the user's weekly wellness avg is low, shift
    // the seed color toward a calming blue-green. Loads async; falls back to
    // default seed until data is available.
    final weekly = ref.watch(weeklyWellnessAvgProvider);
    final palette = ref.watch(paletteProvider);
    final seed = AppTheme.resolveSeed(palette, weekly.asData?.value);
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
