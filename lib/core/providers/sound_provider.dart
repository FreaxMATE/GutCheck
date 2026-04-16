import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Toggles the playful UI sound effects (ingredient "gurgle", etc.).
/// Disabled by default — users must opt in.
class SoundEnabledNotifier extends StateNotifier<bool> {
  static const _key = 'sound_enabled';

  SoundEnabledNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

final soundEnabledProvider =
    StateNotifierProvider<SoundEnabledNotifier, bool>(
  (ref) => SoundEnabledNotifier(),
);

/// Plays a subtle "gurgle" when the user adds an ingredient, if sounds are
/// enabled. Uses [SystemSound] so we don't need an audio package or asset.
Future<void> playGurgle(WidgetRef ref) async {
  final enabled = ref.read(soundEnabledProvider);
  if (!enabled) return;
  // SystemSoundType.click is the subtlest built-in sound available cross
  // platform. On mobile this will use the system click sound.
  await SystemSound.play(SystemSoundType.click);
  await HapticFeedback.lightImpact();
}
