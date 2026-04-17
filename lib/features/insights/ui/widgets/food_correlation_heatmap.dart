import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../domain/correlation_engine.dart';
import '../../domain/impact_score.dart';

/// A food × time-zone correlation matrix.
///
/// Rows  = food items (sorted by |pearsonR|, highest first).
/// Columns = the three named time zones (Immediate / Delayed / Overnight).
/// Cell color: red (r = -1) → white (r = 0) → green (r = +1).
class FoodCorrelationHeatmap extends StatelessWidget {
  final List<ImpactScore> scores;

  static const _rowHeight = 44.0;
  static const _labelWidth = 120.0;
  static const _cellWidth = 72.0;

  const FoodCorrelationHeatmap({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topScores = scores.take(12).toList();
    final zones = CorrelationEngine.timeZones;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          SizedBox(
            height: 44,
            child: Row(
              children: [
                const SizedBox(width: _labelWidth),
                ...zones.map(
                  (z) => SizedBox(
                    width: _cellWidth,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            z.label,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            z.shortLabel,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Data rows
          ...topScores.map((score) => _DataRow(score: score, zones: zones)),
          // Legend
          const SizedBox(height: 16),
          _Legend(),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final ImpactScore score;
  final List<({int from, int to, String label, String shortLabel})> zones;

  const _DataRow({required this.score, required this.zones});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: FoodCorrelationHeatmap._rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: FoodCorrelationHeatmap._labelWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                score.ingredientName,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ...zones.map((z) => _Cell(pearsonR: score.pearsonByLag[z.from])),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final double? pearsonR;

  const _Cell({this.pearsonR});

  @override
  Widget build(BuildContext context) {
    final r = pearsonR;
    final Color cellColor;
    final String label;

    if (r == null) {
      cellColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      label = '—';
    } else {
      cellColor = _correlationColor(r);
      label = '${(r.abs() * 100).round()}%';
    }

    return SizedBox(
      width: FoodCorrelationHeatmap._cellWidth,
      height: FoodCorrelationHeatmap._rowHeight,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: r == null
                  ? Colors.grey
                  : r.abs() > 0.4
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  static Color _correlationColor(double r) {
    final intensity = r.abs().clamp(0.0, 1.0);
    if (r < 0) {
      return Color.lerp(
        const Color(0xFFFFEBEE),
        const Color(0xFFD32F2F),
        intensity,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFE8F5E9),
        const Color(0xFF388E3C),
        intensity,
      )!;
    }
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendSwatch(const Color(0xFFD32F2F)),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context)!.heatmapHarmful, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 16),
          _legendSwatch(const Color(0xFF388E3C)),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context)!.heatmapBeneficial, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 16),
          _legendSwatch(Colors.grey.shade300),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context)!.heatmapNoData, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _legendSwatch(Color color) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      );
}
