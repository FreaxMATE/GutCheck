import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';

class WellnessScoreRing extends ConsumerWidget {
  final double score;
  final double size;

  const WellnessScoreRing({
    super.key,
    required this.score,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(animationsEnabledProvider);
    final duration = enabled
        ? const Duration(milliseconds: 500)
        : Duration.zero;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: score.clamp(0, 100).toDouble()),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (_, value, __) {
          final color = AppColors.wellnessScoreInterpolated(value);
          return CustomPaint(
            painter: _RingPainter(score: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.round().toString(),
                    style: TextStyle(
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'score',
                    style: TextStyle(
                      fontSize: size * 0.10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score;
  final Color color;

  const _RingPainter({required this.score, required this.color});

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
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress ring
    final sweep = (score / 100.0).clamp(0.0, 1.0) * (3 * pi / 2);
    if (sweep > 0) {
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
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
