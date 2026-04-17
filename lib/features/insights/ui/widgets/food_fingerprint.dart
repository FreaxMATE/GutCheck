import 'dart:math';

import 'package:flutter/material.dart';

import '../../../wellness/data/models/wellness_entry.dart';
import '../../../meal_log/data/models/meal_entry.dart';

/// A radar/spider chart showing a food's "fingerprint" across 4 symptom axes.
///
/// Each axis goes from 0 (center, no effect) to 10 (edge, strong effect).
/// The shape formed by connecting the 4 points is the food's fingerprint.
class FoodFingerprint extends StatelessWidget {
  final String foodName;
  final FoodFingerprintData data;
  final double size;

  const FoodFingerprint({
    super.key,
    required this.foodName,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(foodName,
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${data.sampleCount} data points',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadarPainter(data: data),
          ),
        ),
      ],
    );
  }
}

/// Pre-computed fingerprint data for a single food.
class FoodFingerprintData {
  /// Average discomfort (0-10) after eating this food.
  final double discomfort;

  /// Average heartburn (0-10).
  final double heartburn;

  /// Diarrhea rate (0-10 scale: 0 = never, 10 = always).
  final double diarrhea;

  /// Average stress on days this food was eaten (context, not caused by food).
  final double stress;

  final int sampleCount;

  const FoodFingerprintData({
    required this.discomfort,
    required this.heartburn,
    required this.diarrhea,
    required this.stress,
    required this.sampleCount,
  });

  List<double> get axes => [discomfort, heartburn, diarrhea, stress];

  /// Overall "danger" score: avg of all axes. Higher = worse.
  double get dangerScore =>
      (discomfort + heartburn + diarrhea) / 3.0; // stress excluded — it's input
}

/// Compute fingerprints for all foods that appear >= [minSamples] times.
Map<int, FoodFingerprintData> computeFingerprints({
  required List<MealEntry> meals,
  required List<WellnessEntry> wellness,
  int minSamples = 3,
}) {
  // For each meal, find wellness entries in the 4-12h window.
  // Group by ingredient ID.
  final Map<int, List<WellnessEntry>> ingredientWellness = {};
  final Map<int, String> ingredientNames = {};

  for (final meal in meals) {
    final windowStart = meal.consumedAt.add(const Duration(hours: 4));
    final windowEnd = meal.consumedAt.add(const Duration(hours: 12));

    final matched = wellness
        .where((w) =>
            !w.recordedAt.isBefore(windowStart) &&
            w.recordedAt.isBefore(windowEnd))
        .toList();

    if (matched.isEmpty) continue;

    for (final item in meal.ingredients) {
      ingredientWellness
          .putIfAbsent(item.ingredientId, () => [])
          .addAll(matched);
      ingredientNames.putIfAbsent(item.ingredientId, () => item.ingredientName);
    }
  }

  final results = <int, FoodFingerprintData>{};

  for (final entry in ingredientWellness.entries) {
    final entries = entry.value;
    if (entries.length < minSamples) continue;

    final avgDiscomfort =
        entries.map((e) => e.gutPeaceDisplay).reduce((a, b) => a + b) /
            entries.length;
    final avgHeartburn =
        entries.map((e) => e.heartburnDisplay).reduce((a, b) => a + b) /
            entries.length;
    final diarrheaRate =
        entries.where((e) => e.diarrhea).length / entries.length * 10.0;
    final avgStress =
        entries.map((e) => e.stressDisplay).reduce((a, b) => a + b) /
            entries.length;

    results[entry.key] = FoodFingerprintData(
      discomfort: avgDiscomfort,
      heartburn: avgHeartburn,
      diarrhea: diarrheaRate,
      stress: avgStress,
      sampleCount: entries.length,
    );
  }

  return results;
}

// ── Radar chart painter ──────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  final FoodFingerprintData data;

  static const _axisLabels = ['Discomfort', 'Heartburn', 'Diarrhea', 'Stress'];
  static const _axisCount = 4;

  _RadarPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.78;
    final labelRadius = size.width / 2 * 0.95;

    // Draw concentric guide rings (at 25%, 50%, 75%, 100%).
    final guidePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int ring = 1; ring <= 4; ring++) {
      final r = maxRadius * ring / 4;
      final path = Path();
      for (int i = 0; i < _axisCount; i++) {
        final angle = _angleFor(i);
        final p = center + Offset(cos(angle) * r, sin(angle) * r);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, guidePaint);
    }

    // Draw axis lines.
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    for (int i = 0; i < _axisCount; i++) {
      final angle = _angleFor(i);
      final end = center + Offset(cos(angle) * maxRadius, sin(angle) * maxRadius);
      canvas.drawLine(center, end, axisPaint);
    }

    // Draw the food's shape.
    final values = data.axes;
    final shapePath = Path();
    final shapePoints = <Offset>[];
    for (int i = 0; i < _axisCount; i++) {
      final angle = _angleFor(i);
      final r = maxRadius * (values[i] / 10.0).clamp(0.0, 1.0);
      final p = center + Offset(cos(angle) * r, sin(angle) * r);
      shapePoints.add(p);
      i == 0 ? shapePath.moveTo(p.dx, p.dy) : shapePath.lineTo(p.dx, p.dy);
    }
    shapePath.close();

    // Determine color based on danger score.
    final danger = data.dangerScore / 10.0;
    final shapeColor = Color.lerp(
      const Color(0xFF4CAF50), // green
      const Color(0xFFE53935), // red
      danger.clamp(0.0, 1.0),
    )!;

    // Fill.
    canvas.drawPath(
      shapePath,
      Paint()..color = shapeColor.withValues(alpha: 0.25),
    );
    // Stroke.
    canvas.drawPath(
      shapePath,
      Paint()
        ..color = shapeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots at vertices.
    for (final p in shapePoints) {
      canvas.drawCircle(p, 3.5, Paint()..color = shapeColor);
    }

    // Axis labels.
    for (int i = 0; i < _axisCount; i++) {
      final angle = _angleFor(i);
      final pos = center + Offset(cos(angle) * labelRadius, sin(angle) * labelRadius);
      final tp = TextPainter(
        text: TextSpan(
          text: _axisLabels[i],
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  double _angleFor(int index) =>
      -pi / 2 + (2 * pi / _axisCount) * index;

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.data != data;
}
