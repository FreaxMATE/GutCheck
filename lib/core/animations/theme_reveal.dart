import 'dart:math';

import 'package:flutter/material.dart';

/// Plays a brief circular reveal animation from [origin] filled with
/// [color], then invokes [applyTheme] and fades the overlay out.
///
/// Gives the illusion that the tap "poured" the new theme across the screen.
Future<void> showThemeReveal({
  required BuildContext context,
  required Offset origin,
  required Color color,
  required Future<void> Function() applyTheme,
}) async {
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(
    builder: (_) => _RevealOverlay(origin: origin, color: color),
  );
  overlay.insert(entry);
  // Let the reveal expand almost fully before swapping the theme.
  await Future<void>.delayed(const Duration(milliseconds: 260));
  await applyTheme();
  await Future<void>.delayed(const Duration(milliseconds: 250));
  entry.remove();
}

class _RevealOverlay extends StatefulWidget {
  final Offset origin;
  final Color color;
  const _RevealOverlay({required this.origin, required this.color});

  @override
  State<_RevealOverlay> createState() => _RevealOverlayState();
}

class _RevealOverlayState extends State<_RevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Max radius = distance from origin to the farthest screen corner.
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    final maxRadius = corners
        .map((c) => (c - widget.origin).distance)
        .reduce(max);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = Curves.easeOutCubic.transform(_c.value);
          final radius = maxRadius * t;
          // Fade out the tail of the animation so the overlay vanishes.
          final opacity = _c.value < 0.75
              ? 1.0
              : 1.0 - (_c.value - 0.75) / 0.25;
          return CustomPaint(
            painter: _RevealPainter(
              origin: widget.origin,
              radius: radius,
              color: widget.color.withValues(alpha: opacity),
            ),
            size: size,
          );
        },
      ),
    );
  }
}

class _RevealPainter extends CustomPainter {
  final Offset origin;
  final double radius;
  final Color color;

  _RevealPainter({
    required this.origin,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(origin, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RevealPainter old) =>
      old.radius != radius || old.color != color || old.origin != origin;
}
