import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Minimal shake detector using the accelerometer. Invokes [onShake] when
/// the device is moved sharply. Debounces to avoid firing more than once per
/// gesture.
class ShakeDetector {
  final VoidCallback onShake;
  final double threshold; // m/s^2 above gravity
  final Duration debounce;

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _lastFired = DateTime.fromMillisecondsSinceEpoch(0);

  ShakeDetector({
    required this.onShake,
    this.threshold = 18.0,
    this.debounce = const Duration(milliseconds: 1200),
  });

  void start() {
    _sub?.cancel();
    _sub = accelerometerEventStream().listen(
      (event) {
        final magnitude = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        if (magnitude > threshold) {
          final now = DateTime.now();
          if (now.difference(_lastFired) > debounce) {
            _lastFired = now;
            onShake();
          }
        }
      },
      onError: (_) {
        /* sensor unavailable on desktop — no-op */
      },
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
