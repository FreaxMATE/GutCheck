import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';

/// A ring gauge that visualises gut discomfort (0-10).
///
/// 0 = none (green, ring nearly empty) → 10 = extreme (red, ring full).
/// The digit animates with a vertical slide + fade when the value changes.
class WellnessScoreRing extends ConsumerWidget {
  final int discomfort;
  final double size;

  const WellnessScoreRing({
    super.key,
    required this.discomfort,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(animationsEnabledProvider);
    final d = discomfort.clamp(0, 10);
    final fraction = d / 10.0;
    final wellnessEquiv = ((10 - d) / 10.0) * 100.0;
    final color = AppColors.wellnessScoreInterpolated(wellnessEquiv);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: fraction),
        duration: enabled ? const Duration(milliseconds: 600) : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (_, t, __) {
          return CustomPaint(
            painter: _DiscomfortRingPainter(fraction: t, color: color),
            child: Center(
              // Animated digit: slides up/down and fades when value changes.
              child: AnimatedSwitcher(
                duration: enabled
                    ? const Duration(milliseconds: 350)
                    : Duration.zero,
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) {
                  // Determine direction: new value slides in from below if
                  // increasing, from above if decreasing.
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '$d',
                  key: ValueKey<int>(d),
                  style: TextStyle(
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiscomfortRingPainter extends CustomPainter {
  final double fraction;
  final Color color;

  const _DiscomfortRingPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.85;
    final strokeWidth = size.width * 0.08;

    // Background ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3 * pi / 4,
      3 * pi / 2,
      false,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Filled arc
    final sweep = fraction.clamp(0.0, 1.0) * (3 * pi / 2);
    if (sweep > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3 * pi / 4,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DiscomfortRingPainter old) =>
      old.fraction != fraction || old.color != color;
}
