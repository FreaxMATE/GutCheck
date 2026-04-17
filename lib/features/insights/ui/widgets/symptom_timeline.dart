import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../meal_log/data/models/meal_entry.dart';
import '../../../wellness/data/models/wellness_entry.dart';
import 'package:gutcheck/l10n/app_localizations.dart';

/// A horizontal timeline showing meals (icons at top) and wellness scores
/// (colored dots at bottom) on a 24h time axis. Scrollable, one strip per day.
class SymptomTimeline extends StatelessWidget {
  final DateTime date;
  final List<MealEntry> meals;
  final List<WellnessEntry> wellness;

  const SymptomTimeline({
    super.key,
    required this.date,
    required this.meals,
    required this.wellness,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            _formatDate(date, l10n),
            style: theme.textTheme.labelLarge?.copyWith(
              color: _isToday(date)
                  ? theme.colorScheme.primary
                  : Colors.grey[700],
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 600, // 24h compressed into 600px
              child: CustomPaint(
                painter: _TimelinePainter(
                  meals: meals,
                  wellness: wellness,
                  textColor: theme.colorScheme.onSurface,
                ),
                size: const Size(600, 120),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _formatDate(DateTime d, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d == today) return l10n.dateToday;
    if (d == today.subtract(const Duration(days: 1))) return l10n.dateYesterday;
    return '${d.day}.${d.month}.${d.year}';
  }
}

class _TimelinePainter extends CustomPainter {
  final List<MealEntry> meals;
  final List<WellnessEntry> wellness;
  final Color textColor;

  _TimelinePainter({
    required this.meals,
    required this.wellness,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mealY = 25.0; // vertical position for meal dots
    final wellnessY = 75.0; // vertical position for wellness dots
    final axisY = h - 12;

    // ── Time axis ────────────────────────────────────────────────────────
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, axisY), Offset(w, axisY), axisPaint);

    // Hour labels
    for (int hour = 0; hour <= 24; hour += 3) {
      final x = (hour / 24.0) * w;
      // Tick
      canvas.drawLine(Offset(x, axisY - 3), Offset(x, axisY + 3), axisPaint);
      // Label
      final label = hour == 0
          ? '0h'
          : hour == 12
          ? '12h'
          : hour == 24
          ? '24h'
          : '${hour}h';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, axisY + 4));
    }

    // ── "Meals" label ────────────────────────────────────────────────────
    final mealLabelTp = TextPainter(
      text: TextSpan(text: '🍽️', style: const TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    mealLabelTp.paint(canvas, Offset(-2, mealY - mealLabelTp.height / 2));

    // ── "Wellness" label ─────────────────────────────────────────────────
    final wellLabelTp = TextPainter(
      text: TextSpan(text: '❤️', style: const TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    wellLabelTp.paint(canvas, Offset(-2, wellnessY - wellLabelTp.height / 2));

    // Neutral steel-blue for meal dots so they don't imply a symptom severity.
    const mealColor = Color(0xFF546E7A);

    // ── Meal dots ────────────────────────────────────────────────────────
    for (final meal in meals) {
      final hour = meal.consumedAt.hour + meal.consumedAt.minute / 60.0;
      final x = (hour / 24.0) * w;

      // Vertical connector line to axis
      canvas.drawLine(
        Offset(x, mealY + 8),
        Offset(x, axisY - 4),
        Paint()
          ..color = mealColor.withValues(alpha: 0.15)
          ..strokeWidth = 1,
      );

      // Meal dot
      canvas.drawCircle(Offset(x, mealY), 6, Paint()..color = mealColor);

      // Ingredient count inside dot
      final countTp = TextPainter(
        text: TextSpan(
          text: '${meal.ingredients.length}',
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      countTp.paint(
        canvas,
        Offset(x - countTp.width / 2, mealY - countTp.height / 2),
      );
    }

    // ── Wellness dots ────────────────────────────────────────────────────
    for (final entry in wellness) {
      final hour = entry.recordedAt.hour + entry.recordedAt.minute / 60.0;
      final x = (hour / 24.0) * w;
      final score = entry.wellnessScore;
      final color = AppColors.wellnessScoreInterpolated(score);

      // Vertical connector
      canvas.drawLine(
        Offset(x, wellnessY + 8),
        Offset(x, axisY - 4),
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..strokeWidth = 1,
      );

      // Wellness dot
      canvas.drawCircle(Offset(x, wellnessY), 7, Paint()..color = color);

      // Display value
      final d = entry.gutPeaceDisplay;
      final valTp = TextPainter(
        text: TextSpan(
          text: d == d.roundToDouble() ? '${d.round()}' : d.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 7,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(
        canvas,
        Offset(x - valTp.width / 2, wellnessY - valTp.height / 2),
      );
    }

    // ── Connection lines: meal → nearest wellness ────────────────────────
    for (final meal in meals) {
      final mealHour = meal.consumedAt.hour + meal.consumedAt.minute / 60.0;
      final mealX = (mealHour / 24.0) * w;

      // Find wellness entries 2-12h after this meal.
      WellnessEntry? closest;
      double closestDist = double.infinity;
      for (final entry in wellness) {
        final diff =
            entry.recordedAt.difference(meal.consumedAt).inMinutes / 60.0;
        if (diff >= 2 && diff <= 12 && diff < closestDist) {
          closestDist = diff;
          closest = entry;
        }
      }
      if (closest != null) {
        final wellHour =
            closest.recordedAt.hour + closest.recordedAt.minute / 60.0;
        final wellX = (wellHour / 24.0) * w;
        final score = closest.wellnessScore;
        final color = AppColors.wellnessScoreInterpolated(score);

        // Curved connecting arc from meal to wellness.
        final path = Path()
          ..moveTo(mealX, mealY + 8)
          ..quadraticBezierTo(
            (mealX + wellX) / 2,
            (mealY + wellnessY) / 2 + 10,
            wellX,
            wellnessY - 8,
          );
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter old) => true;
}
