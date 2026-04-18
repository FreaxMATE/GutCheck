import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_palette.dart';

class PaletteNotifier extends StateNotifier<AppPalette> {
  static const _key = 'app_palette';

  PaletteNotifier() : super(AppPalette.terracottaClay) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppPalette.fromKey(prefs.getString(_key));
  }

  Future<void> setPalette(AppPalette p) async {
    state = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, p.storageKey);
  }
}

final paletteProvider = StateNotifierProvider<PaletteNotifier, AppPalette>(
  (ref) => PaletteNotifier(),
);
