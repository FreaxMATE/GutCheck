import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  /// Default neutral seed (used by adaptive tint).
  static const _baseSeed = AppColors.seedGreen;
  /// Calm seed used when recent wellness scores are low.
  static const _calmSeed = Color(0xFF3E7FA3);

  /// Picks a seed color based on [weeklyWellnessAvg] (0-100, higher=better).
  /// When the user has been having a rough week, shift to a calmer palette.
  /// Used only when the palette is [AppPalette.verdantGreen]; other palettes
  /// opt out of adaptive tint to keep their distinctive look.
  static Color seedFor(double? weeklyWellnessAvg) {
    if (weeklyWellnessAvg == null) return _baseSeed;
    if (weeklyWellnessAvg >= 60) return _baseSeed;
    final t = ((60 - weeklyWellnessAvg) / 60).clamp(0.0, 1.0);
    return Color.lerp(_baseSeed, _calmSeed, t)!;
  }

  /// Resolves the final seed color, considering the user's palette choice
  /// and (for the default palette) the adaptive tint based on recent wellness.
  static Color resolveSeed(AppPalette palette, double? weeklyWellnessAvg) {
    if (palette == AppPalette.verdantGreen) {
      return seedFor(weeklyWellnessAvg);
    }
    return palette.seed;
  }

  static ThemeData light({
    required AppPalette palette,
    Color? seedColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? palette.seed,
      brightness: Brightness.light,
    ).copyWith(
      surface: palette.lightSurfaceOverride,
      surfaceContainerLowest: palette.lightSurfaceOverride,
    );

    final scaffoldBg = palette.lightBackgroundOverride;

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scaffoldBg ?? colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: scaffoldBg ?? colorScheme.surface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scaffoldBg != null
            ? palette.lightSurfaceOverride
            : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  static ThemeData dark({
    required AppPalette palette,
    Color? seedColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? palette.seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
