import 'package:flutter/material.dart';

import 'app_colors.dart';

/// User-selectable color palette for the whole app.
///
/// Each palette drives a Material 3 [ColorScheme.fromSeed] palette plus a
/// few surface-level tweaks (e.g. cream background for the journal theme).
enum AppPalette {
  /// Original verdant green.
  verdantGreen,

  /// #4 Twilight Indigo — serious, tech-forward.
  twilightIndigo,

  /// #6 Peachy Pastel — soft, welcoming.
  peachyPastel,

  /// #9 Warm Cream — paper-journal, cozy.
  warmCream;

  /// The seed color for [ColorScheme.fromSeed].
  Color get seed {
    switch (this) {
      case AppPalette.verdantGreen:
        return AppColors.seedGreen;
      case AppPalette.twilightIndigo:
        return const Color(0xFF3F51B5);
      case AppPalette.peachyPastel:
        return const Color(0xFFC2185B);
      case AppPalette.warmCream:
        return const Color(0xFF1B5E20);
    }
  }

  /// Optional background override (null → use Material 3 default).
  /// Only the cream theme uses this.
  Color? get lightBackgroundOverride {
    switch (this) {
      case AppPalette.warmCream:
        return const Color(0xFFFAF6F0);
      default:
        return null;
    }
  }

  Color? get lightSurfaceOverride {
    switch (this) {
      case AppPalette.warmCream:
        return const Color(0xFFFFFDF8);
      default:
        return null;
    }
  }

  /// Storage key.
  String get storageKey {
    switch (this) {
      case AppPalette.verdantGreen:
        return 'verdantGreen';
      case AppPalette.twilightIndigo:
        return 'twilightIndigo';
      case AppPalette.peachyPastel:
        return 'peachyPastel';
      case AppPalette.warmCream:
        return 'warmCream';
    }
  }

  static AppPalette fromKey(String? key) {
    return AppPalette.values.firstWhere(
      (p) => p.storageKey == key,
      orElse: () => AppPalette.verdantGreen,
    );
  }
}
