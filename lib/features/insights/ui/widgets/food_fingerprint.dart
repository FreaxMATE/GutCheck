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
  final List<String>? axisLabels;

  const FoodFingerprint({
    super.key,
    required this.foodName,
    required this.data,
    this.size = 200,
    this.axisLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          foodName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${data.sampleCount} data points',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadarPainter(
              data: data,
              axisLabels: axisLabels ?? _defaultAxisLabels,
            ),
          ),
        ),
      ],
    );
  }
}

const _defaultAxisLabels = [
  'Discomfort',
  'Bloating',
  'Heartburn',
  'Diarrhea',
];

/// A single food overlaid on a radar chart, exposed so the overlay widget
/// can stack several of them with per-food colors and legends.
class FingerprintLayer {
  final String name;
  final FoodFingerprintData data;
  final Color color;
  const FingerprintLayer({
    required this.name,
    required this.data,
    required this.color,
  });
}

/// Radar chart that overlays multiple food fingerprints so the user can see
/// at a glance which foods push the symptom shape out vs. keep it small.
///
/// Used as the default view when no single food is selected — typically
/// seeded with the 3 "worst" (high dangerScore) + 3 "best" (low dangerScore)
/// foods in the user's log.
class OverlayedFoodFingerprint extends StatelessWidget {
  final List<FingerprintLayer> layers;
  final double size;
  final List<String>? axisLabels;

  const OverlayedFoodFingerprint({
    super.key,
    required this.layers,
    this.size = 260,
    this.axisLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabels = axisLabels ?? _defaultAxisLabels;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _OverlayRadarPainter(
              layers: layers,
              axisLabels: effectiveLabels,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final layer in layers)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: layer.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    layer.name,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Pick the [topN] most-harmful ("worst") and [topN] least-harmful ("best")
/// foods from a fingerprints map, ranked by dangerScore. Requires that at
/// least [topN] foods on each side exist with sample data.
({List<MapEntry<int, FoodFingerprintData>> best,
  List<MapEntry<int, FoodFingerprintData>> worst})
selectBestAndWorstFingerprints(
  Map<int, FoodFingerprintData> fingerprints, {
  int topN = 3,
}) {
  final sorted = fingerprints.entries.toList()
    ..sort((a, b) => b.value.dangerScore.compareTo(a.value.dangerScore));
  if (sorted.isEmpty) return (best: [], worst: []);
  final worst = sorted.take(topN).toList();
  final bestRaw = sorted.reversed.take(topN).toList();
  // If fewer than 2·topN foods exist, avoid showing the same food on both sides.
  final worstIds = worst.map((e) => e.key).toSet();
  final best = bestRaw.where((e) => !worstIds.contains(e.key)).toList();
  return (best: best, worst: worst);
}

/// Pre-computed fingerprint data for a single food.
/// Stress is excluded from the radar — it's an input signal like food,
/// not an output symptom the radar is trying to characterize.
class FoodFingerprintData {
  final double discomfort;
  final double bloating;
  final double heartburn;
  final double diarrhea;
  final int sampleCount;

  /// Denormalized ingredient name (English, stored at log time). Used as
  /// a fallback when the current Ingredient row has been deleted or the
  /// seed re-insert gave it a different auto-increment id.
  final String fallbackName;

  const FoodFingerprintData({
    required this.discomfort,
    required this.bloating,
    required this.heartburn,
    required this.diarrhea,
    required this.sampleCount,
    required this.fallbackName,
  });

  List<double> get axes => [discomfort, bloating, heartburn, diarrhea];

  /// Overall "danger" score: avg of the four symptom axes.
  double get dangerScore =>
      (discomfort + bloating + heartburn + diarrhea) / 4.0;
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
        .where(
          (w) =>
              !w.recordedAt.isBefore(windowStart) &&
              w.recordedAt.isBefore(windowEnd),
        )
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
    final avgBloating =
        entries.map((e) => e.bloatingDisplay).reduce((a, b) => a + b) /
        entries.length;
    final avgHeartburn =
        entries.map((e) => e.heartburnDisplay).reduce((a, b) => a + b) /
        entries.length;
    final diarrheaRate =
        entries.where((e) => e.diarrhea).length / entries.length * 10.0;

    results[entry.key] = FoodFingerprintData(
      discomfort: avgDiscomfort,
      bloating: avgBloating,
      heartburn: avgHeartburn,
      diarrhea: diarrheaRate,
      sampleCount: entries.length,
      fallbackName: ingredientNames[entry.key] ?? 'Unknown',
    );
  }

  return results;
}

// ── Radar chart painter ──────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  final FoodFingerprintData data;
  final List<String> axisLabels;

  static const _axisCount = 4;

  _RadarPainter({
    required this.data,
    this.axisLabels = const [
      'Discomfort',
      'Bloating',
      'Heartburn',
      'Diarrhea',
    ],
  });

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
      final end =
          center + Offset(cos(angle) * maxRadius, sin(angle) * maxRadius);
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
      final pos =
          center + Offset(cos(angle) * labelRadius, sin(angle) * labelRadius);
      final tp = TextPainter(
        text: TextSpan(
          text: axisLabels[i],
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  double _angleFor(int index) => -pi / 2 + (2 * pi / _axisCount) * index;

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.data != data;
}

class _OverlayRadarPainter extends CustomPainter {
  final List<FingerprintLayer> layers;
  final List<String> axisLabels;
  static const _axisCount = 4;

  _OverlayRadarPainter({required this.layers, required this.axisLabels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.78;
    final labelRadius = size.width / 2 * 0.95;

    // Guide rings + axis lines (same as single-food painter).
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
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    for (int i = 0; i < _axisCount; i++) {
      final angle = _angleFor(i);
      final end =
          center + Offset(cos(angle) * maxRadius, sin(angle) * maxRadius);
      canvas.drawLine(center, end, axisPaint);
    }

    // Overlay each layer as a translucent fill + stroke.
    for (final layer in layers) {
      final values = layer.data.axes;
      final shapePath = Path();
      final points = <Offset>[];
      for (int i = 0; i < _axisCount; i++) {
        final angle = _angleFor(i);
        final r = maxRadius * (values[i] / 10.0).clamp(0.0, 1.0);
        final p = center + Offset(cos(angle) * r, sin(angle) * r);
        points.add(p);
        i == 0 ? shapePath.moveTo(p.dx, p.dy) : shapePath.lineTo(p.dx, p.dy);
      }
      shapePath.close();

      canvas.drawPath(
        shapePath,
        Paint()..color = layer.color.withValues(alpha: 0.14),
      );
      canvas.drawPath(
        shapePath,
        Paint()
          ..color = layer.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeJoin = StrokeJoin.round,
      );
      for (final p in points) {
        canvas.drawCircle(p, 2.5, Paint()..color = layer.color);
      }
    }

    // Axis labels on top.
    for (int i = 0; i < _axisCount; i++) {
      final angle = _angleFor(i);
      final pos =
          center + Offset(cos(angle) * labelRadius, sin(angle) * labelRadius);
      final tp = TextPainter(
        text: TextSpan(
          text: axisLabels[i],
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  double _angleFor(int index) => -pi / 2 + (2 * pi / _axisCount) * index;

  @override
  bool shouldRepaint(covariant _OverlayRadarPainter old) =>
      old.layers != layers;
}
