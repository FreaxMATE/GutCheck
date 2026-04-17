import 'package:flutter/material.dart';

import 'app_colors.dart';

/// User-selectable color palette for the whole app.
enum AppPalette {
  /// Original verdant green.
  verdantGreen,

  /// Twilight Indigo — serious, tech-forward.
  twilightIndigo;

  /// The seed color for [ColorScheme.fromSeed].
  Color get seed {
    switch (this) {
      case AppPalette.verdantGreen:
        return AppColors.seedGreen;
      case AppPalette.twilightIndigo:
        return const Color(0xFF3F51B5);
    }
  }

  /// Optional background override (null → use Material 3 default).
  Color? get lightBackgroundOverride => null;

  Color? get lightSurfaceOverride => null;

  /// Stable storage key (persists across renames).
  String get storageKey {
    switch (this) {
      case AppPalette.verdantGreen:
        return 'verdantGreen';
      case AppPalette.twilightIndigo:
        return 'twilightIndigo';
    }
  }

  static AppPalette fromKey(String? key) {
    return AppPalette.values.firstWhere(
      (p) => p.storageKey == key,
      orElse: () => AppPalette.verdantGreen,
    );
  }
}
