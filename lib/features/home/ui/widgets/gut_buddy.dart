import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/animations.dart';

/// Gut Buddy 🦠 — a playful mascot that reacts to the user's latest
/// gut-discomfort value (0 = happy, 10 = miserable). Breathes gently when
/// idle; expression changes across 4 tiers.
class GutBuddy extends ConsumerStatefulWidget {
  /// Latest discomfort value (0-10). null → cheerful default.
  final int? discomfort;
  final double size;

  const GutBuddy({
    super.key,
    this.discomfort,
    this.size = 120,
  });

  @override
  ConsumerState<GutBuddy> createState() => _GutBuddyState();
}

class _GutBuddyState extends ConsumerState<GutBuddy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animsOn = ref.watch(animationsEnabledProvider);
    final d = (widget.discomfort ?? 0).clamp(0, 10);
    final mood = _moodFor(d);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: animsOn
          ? AnimatedBuilder(
              animation: _breath,
              builder: (_, __) {
                final t = Curves.easeInOut.transform(_breath.value);
                // Breathe faster when uncomfortable.
                final rate = 1.0 + (d / 10) * 0.25;
                final scale = 0.97 + sin(t * pi * rate) * 0.03;
                return Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    painter: _GutBuddyPainter(mood: mood, discomfort: d),
                  ),
                );
              },
            )
          : CustomPaint(
              painter: _GutBuddyPainter(mood: mood, discomfort: d),
            ),
    );
  }

  _Mood _moodFor(int d) {
    if (d <= 2) return _Mood.happy;
    if (d <= 5) return _Mood.neutral;
    if (d <= 8) return _Mood.worried;
    return _Mood.miserable;
  }
}

enum _Mood { happy, neutral, worried, miserable }

class _GutBuddyPainter extends CustomPainter {
  final _Mood mood;
  final int discomfort;

  _GutBuddyPainter({required this.mood, required this.discomfort});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Color shifts from healthy pink → pale → greyish as discomfort rises.
    final healthy = const Color(0xFFF4A6A0); // warm salmon pink
    final pale = const Color(0xFFE5C3B9);
    final sick = const Color(0xFFB5B2A3); // greyish olive
    final t = (discomfort / 10).clamp(0.0, 1.0);
    final bodyColor = t < 0.5
        ? Color.lerp(healthy, pale, t * 2)!
        : Color.lerp(pale, sick, (t - 0.5) * 2)!;

    // ── Body (rounded blob) ──────────────────────────────────────────────
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.02),
      width: w * 0.75,
      height: h * 0.72,
    );
    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        bodyRect,
        Radius.circular(w * 0.32),
      ));
    canvas.drawShadow(bodyPath, Colors.black.withValues(alpha: 0.15), 6, false);
    canvas.drawPath(bodyPath, Paint()..color = bodyColor);

    // Subtle highlight for body
    final highlight = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx - w * 0.14, cy - h * 0.12),
        width: w * 0.22,
        height: h * 0.14,
      ));
    canvas.drawPath(
      highlight,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    // ── Eyes ──────────────────────────────────────────────────────────────
    final eyeY = cy - h * 0.05;
    final eyeDX = w * 0.14;
    final eyeRadius = w * 0.035;
    final eyePaint = Paint()..color = const Color(0xFF2E2A2A);

    if (mood == _Mood.miserable) {
      // X eyes: dead-inside mode
      final xPaint = Paint()
        ..color = const Color(0xFF2E2A2A)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (final side in [-1, 1]) {
        final ex = cx + side * eyeDX;
        canvas.drawLine(
            Offset(ex - 5, eyeY - 5), Offset(ex + 5, eyeY + 5), xPaint);
        canvas.drawLine(
            Offset(ex - 5, eyeY + 5), Offset(ex + 5, eyeY - 5), xPaint);
      }
    } else {
      canvas.drawCircle(Offset(cx - eyeDX, eyeY), eyeRadius, eyePaint);
      canvas.drawCircle(Offset(cx + eyeDX, eyeY), eyeRadius, eyePaint);
      // Tiny white glint for liveliness (happy only)
      if (mood == _Mood.happy) {
        final glint = Paint()..color = Colors.white;
        canvas.drawCircle(
            Offset(cx - eyeDX + 1.5, eyeY - 1.5), 1.2, glint);
        canvas.drawCircle(
            Offset(cx + eyeDX + 1.5, eyeY - 1.5), 1.2, glint);
      }
    }

    // ── Cheeks (soft blush when happy) ────────────────────────────────────
    if (mood == _Mood.happy) {
      final blush = Paint()..color = const Color(0xFFE8837B).withValues(alpha: 0.5);
      canvas.drawCircle(Offset(cx - w * 0.24, cy + h * 0.02), w * 0.05, blush);
      canvas.drawCircle(Offset(cx + w * 0.24, cy + h * 0.02), w * 0.05, blush);
    }

    // ── Mouth ─────────────────────────────────────────────────────────────
    final mouthPaint = Paint()
      ..color = const Color(0xFF2E2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final mouthCenter = Offset(cx, cy + h * 0.12);
    final mouthWidth = w * 0.18;
    final mouthPath = Path();

    switch (mood) {
      case _Mood.happy:
        mouthPath.moveTo(mouthCenter.dx - mouthWidth, mouthCenter.dy - 3);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx, mouthCenter.dy + mouthWidth * 0.55,
          mouthCenter.dx + mouthWidth, mouthCenter.dy - 3,
        );
        break;
      case _Mood.neutral:
        mouthPath.moveTo(mouthCenter.dx - mouthWidth * 0.7, mouthCenter.dy);
        mouthPath.lineTo(mouthCenter.dx + mouthWidth * 0.7, mouthCenter.dy);
        break;
      case _Mood.worried:
        // Small upside-down arc
        mouthPath.moveTo(mouthCenter.dx - mouthWidth * 0.8,
            mouthCenter.dy + mouthWidth * 0.25);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx, mouthCenter.dy - mouthWidth * 0.3,
          mouthCenter.dx + mouthWidth * 0.8,
              mouthCenter.dy + mouthWidth * 0.25,
        );
        break;
      case _Mood.miserable:
        // Squiggle mouth
        final step = mouthWidth * 2 / 4;
        mouthPath.moveTo(mouthCenter.dx - mouthWidth, mouthCenter.dy);
        for (int i = 1; i <= 4; i++) {
          final x = mouthCenter.dx - mouthWidth + step * i;
          final y =
              mouthCenter.dy + (i.isOdd ? mouthWidth * 0.18 : -mouthWidth * 0.18);
          mouthPath.lineTo(x, y);
        }
        break;
    }
    canvas.drawPath(mouthPath, mouthPaint);

    // ── Sweat drops when miserable ────────────────────────────────────────
    if (mood == _Mood.miserable) {
      final drop = Paint()..color = const Color(0xFF8FC8E6);
      final dropPath = Path()
        ..moveTo(cx + w * 0.34, cy - h * 0.14)
        ..quadraticBezierTo(cx + w * 0.40, cy - h * 0.08,
            cx + w * 0.34, cy - h * 0.04)
        ..quadraticBezierTo(
            cx + w * 0.28, cy - h * 0.08, cx + w * 0.34, cy - h * 0.14)
        ..close();
      canvas.drawPath(dropPath, drop);
    }
  }

  @override
  bool shouldRepaint(covariant _GutBuddyPainter old) =>
      old.mood != mood || old.discomfort != discomfort;
}
