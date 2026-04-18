import 'package:flutter/material.dart';

import 'app_colors.dart';

/// User-selectable color palette for the whole app.
enum AppPalette {
  /// Original verdant green.
  verdantGreen,

  /// Twilight Indigo — serious, tech-forward.
  twilightIndigo,

  /// Terracotta Clay — matches the GutCheck app icon (warm, earthy).
  terracottaClay;

  /// The seed color for [ColorScheme.fromSeed].
  Color get seed {
    switch (this) {
      case AppPalette.verdantGreen:
        return AppColors.seedGreen;
      case AppPalette.twilightIndigo:
        return const Color(0xFF3F51B5);
      case AppPalette.terracottaClay:
        return const Color(0xFFD97757);
    }
  }

  /// Optional background override (null → use Material 3 default).
  Color? get lightBackgroundOverride {
    switch (this) {
      case AppPalette.terracottaClay:
        return const Color(0xFFFBEFE3);
      default:
        return null;
    }
  }

  Color? get lightSurfaceOverride {
    switch (this) {
      case AppPalette.terracottaClay:
        return const Color(0xFFFFF8F0);
      default:
        return null;
    }
  }

  /// Stable storage key (persists across renames).
  String get storageKey {
    switch (this) {
      case AppPalette.verdantGreen:
        return 'verdantGreen';
      case AppPalette.twilightIndigo:
        return 'twilightIndigo';
      case AppPalette.terracottaClay:
        return 'terracottaClay';
    }
  }

  static AppPalette fromKey(String? key) {
    return AppPalette.values.firstWhere(
      (p) => p.storageKey == key,
      orElse: () => AppPalette.terracottaClay,
    );
  }
}
