import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../domain/impact_score.dart';

/// Card shown at the top of the Impact list. Reports how the user's
/// self-reported stress correlates with the currently selected symptom
/// metric. Stress is treated as an INPUT (like food), not a symptom.
class StressImpactCard extends StatelessWidget {
  final StressImpact impact;

  const StressImpactCard({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final harmful = impact.isHarmful;
    final barColor = harmful ? Colors.red : Colors.green;
    final pct = impact.correlationPercent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.insightsStressCardTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (impact.isNominallySignificant)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.insightsScatterSignificant,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: barColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (pct / 100.0).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: barColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(barColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  harmful
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: barColor,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _summary(impact, l10n),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (impact.sampleCount < 10)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.impactDataPoints(impact.sampleCount),
                  style: TextStyle(fontSize: 10, color: Colors.orange[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _summary(StressImpact s, AppLocalizations l10n) {
    if (s.sampleCount < 3) return l10n.impactNotEnoughData;
    return s.isHarmful
        ? l10n.insightsStressCardHarmful(s.correlationPercent)
        : l10n.insightsStressCardBeneficial(s.correlationPercent);
  }
}
