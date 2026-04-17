import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/food_categories.dart';

/// A circular "plate" that fills with colored segments per food category as
/// ingredients are added. Animates smoothly between states.
class MealPlate extends StatelessWidget {
  /// Count of ingredients per category. An empty / all-zero map renders as
  /// an empty dashed plate.
  final Map<FoodCategory, int> categoryCounts;
  final double size;

  const MealPlate({super.key, required this.categoryCounts, this.size = 90});

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final e in categoryCounts.entries)
        if (e.value > 0) e.key: e.value,
    };
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: total == 0 ? 0 : 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (_, t, __) => CustomPaint(
          painter: _MealPlatePainter(
            counts: counts,
            total: total,
            sweepFraction: t,
          ),
        ),
      ),
    );
  }
}

class _MealPlatePainter extends CustomPainter {
  final Map<FoodCategory, int> counts;
  final int total;
  final double sweepFraction; // 0..1 for overall fill-in animation

  _MealPlatePainter({
    required this.counts,
    required this.total,
    required this.sweepFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.62;

    // Outer plate rim
    final plateRim = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(center, radius - 1, plateRim);

    // Empty plate background
    final plateBg = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawCircle(center, radius - 2, plateBg);

    if (total == 0) {
      // Dashed empty hint
      final dashPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      for (double a = 0; a < 2 * pi; a += pi / 8) {
        final p1 =
            center + Offset(cos(a) * (radius - 10), sin(a) * (radius - 10));
        final p2 =
            center +
            Offset(
              cos(a + pi / 16) * (radius - 10),
              sin(a + pi / 16) * (radius - 10),
            );
        canvas.drawLine(p1, p2, dashPaint);
      }
      return;
    }

    // Draw one arc per category. Sweep to sweepFraction of full circle.
    const startAngle = -pi / 2;
    double currentAngle = startAngle;
    final targetFullSweep = 2 * pi * sweepFraction;

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in entries) {
      final slice = entry.value / total * targetFullSweep;
      final paint = Paint()..color = entry.key.color.withValues(alpha: 0.88);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        currentAngle,
        slice,
        true,
        paint,
      );
      currentAngle += slice;
    }

    // Inner hole — gives it that "plate" look instead of pie.
    final hole = Paint()..color = const Color(0xFFFDFDFD);
    canvas.drawCircle(center, innerRadius, hole);

    // Center count
    final tp = TextPainter(
      text: TextSpan(
        text: '$total',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: Color(0xFF424242),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MealPlatePainter old) =>
      old.total != total ||
      old.sweepFraction != sweepFraction ||
      !_mapsEqual(old.counts, counts);

  bool _mapsEqual(Map<FoodCategory, int> a, Map<FoodCategory, int> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}
