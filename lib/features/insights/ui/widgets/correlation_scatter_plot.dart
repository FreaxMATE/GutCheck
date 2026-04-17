import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../pantry/providers/pantry_providers.dart';

class CorrelationScatterPlot extends ConsumerWidget {
  final int ingredientId;
  final String ingredientName;
  final List<ScatterSpot> spots;
  final double medianScore;

  const CorrelationScatterPlot({
    super.key,
    required this.ingredientId,
    required this.ingredientName,
    required this.spots,
    required this.medianScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final ingAsync = ref.watch(singleIngredientProvider(ingredientId));
    final displayName = ingAsync.maybeWhen(
      data: (ing) => ing?.localizedName(locale) ?? ingredientName,
      orElse: () => ingredientName,
    );

    if (spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.scatter_plot, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Not enough data for $displayName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            displayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
            child: ScatterChart(
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutCubic,
              ScatterChartData(
                scatterSpots: spots,
                minX: 0,
                maxX: 24,
                minY: 0,
                maxY: 100,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                        '${AppLocalizations.of(context)!.scatterWellnessScore} (0–10)',
                        style: const TextStyle(fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      // Show 0-10 labels instead of the internal 0-100 range.
                      getTitlesWidget: (v, meta) => Text(
                        '${(v / 10).round()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                        AppLocalizations.of(context)!.scatterTimeOfDay,
                        style: const TextStyle(fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, meta) {
                        final h = v.toInt();
                        if (h % 6 != 0) return const SizedBox.shrink();
                        return Text(
                          h == 0
                              ? '12am'
                              : h == 12
                                  ? '12pm'
                                  : h < 12
                                      ? '${h}am'
                                      : '${h - 12}pm',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                // ScatterChartData does not support extraLinesData;
                // median reference is shown via a custom ScatterSpot row instead.
              ),
            ),
          ),
        ),
      ],
    );
  }

  static List<ScatterSpot> buildSpots({
    required List<DateTime> mealTimes,
    required Map<DateTime, double> dailyScores,
    required Color color,
  }) {
    return mealTimes.map((t) {
      final day = DateTime(t.year, t.month, t.day);
      final score = dailyScores[day] ?? 50.0;
      return ScatterSpot(
        t.hour + t.minute / 60.0,
        score,
        dotPainter: FlDotCirclePainter(
          radius: 6,
          color: color.withOpacity(0.8),
          strokeWidth: 1.5,
          strokeColor: color,
        ),
      );
    }).toList();
  }
}
