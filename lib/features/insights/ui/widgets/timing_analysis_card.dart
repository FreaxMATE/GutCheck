import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/timing_analysis.dart';

/// Displays meal-timing analysis: "When you eat at X, you feel Y."
///
/// Shows a horizontal bar chart of avg discomfort per time-of-day bucket,
/// plus a summary sentence highlighting the best and worst windows.
class TimingAnalysisCard extends StatelessWidget {
  final TimingAnalysis analysis;

  const TimingAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final buckets = analysis.buckets;
    if (buckets.isEmpty) return const SizedBox.shrink();

    final maxD = buckets
        .map((b) => b.avgDiscomfort)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, 10.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.timingTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.timingSubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 14),

            // Bar chart
            for (final b in buckets) ...[
              _TimingBar(bucket: b, maxDiscomfort: maxD),
              const SizedBox(height: 6),
            ],

            // Summary insights
            if (analysis.bestBucket != null && analysis.worstBucket != null &&
                analysis.bestBucket != analysis.worstBucket) ...[
              const Divider(height: 24),
              _InsightRow(
                icon: Icons.thumb_up_rounded,
                color: Colors.green,
                text: l10n.timingBestWindow(
                  analysis.bestBucket!.label,
                  analysis.bestBucket!.shortLabel,
                  analysis.bestBucket!.avgDiscomfort.toStringAsFixed(1),
                ),
              ),
              const SizedBox(height: 4),
              _InsightRow(
                icon: Icons.thumb_down_rounded,
                color: Colors.red,
                text: l10n.timingWorstWindow(
                  analysis.worstBucket!.label,
                  analysis.worstBucket!.shortLabel,
                  analysis.worstBucket!.avgDiscomfort.toStringAsFixed(1),
                ),
              ),
            ],

            if (analysis.lateEatingPenalty != null) ...[
              const SizedBox(height: 4),
              _InsightRow(
                icon: analysis.lateEatingPenalty! > 0.5
                    ? Icons.nightlight_round
                    : Icons.check_circle_outline,
                color: analysis.lateEatingPenalty! > 0.5
                    ? Colors.orange
                    : Colors.green,
                text: analysis.lateEatingPenalty! > 0.5
                    ? l10n.timingLateEatingBad(
                        analysis.lateEatingPenalty!.toStringAsFixed(1))
                    : l10n.timingLateEatingOk,
              ),
            ],

            if (analysis.avgMealGapHours != null) ...[
              const SizedBox(height: 4),
              _InsightRow(
                icon: Icons.timelapse_rounded,
                color: Colors.blueGrey,
                text: l10n.timingAvgGap(
                    analysis.avgMealGapHours!.toStringAsFixed(1)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimingBar extends StatelessWidget {
  final TimingBucketResult bucket;
  final double maxDiscomfort;
  const _TimingBar({required this.bucket, required this.maxDiscomfort});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = (bucket.avgDiscomfort / maxDiscomfort).clamp(0.0, 1.0);
    // Color: higher discomfort = more red
    final wellnessEquiv = ((10 - bucket.avgDiscomfort.clamp(0, 10)) / 10) * 100;
    final color = AppColors.wellnessScoreInterpolated(wellnessEquiv);

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            bucket.shortLabel,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: 18,
                    width: constraints.maxWidth * fraction,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            bucket.avgDiscomfort.toStringAsFixed(1),
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${bucket.mealCount})',
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
