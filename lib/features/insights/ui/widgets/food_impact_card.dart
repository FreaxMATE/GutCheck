import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../pantry/ui/widgets/localized_ingredient_name.dart';
import '../../domain/impact_score.dart';
import '../../providers/insights_providers.dart';

class FoodImpactCard extends ConsumerWidget {
  final ImpactScore score;

  const FoodImpactCard({super.key, required this.score});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cat = score.category;
    final pct = score.correlationPercent;
    final isHarmful = score.isHarmful;
    final barColor = isHarmful ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref
            .read(selectedImpactScoreProvider.notifier)
            .state = score,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category dot
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: LocalizedIngredientText(
                      ingredientId: score.ingredientId,
                      fallbackName: score.ingredientName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  // Lag badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '~${score.bestLagHours}h',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Correlation bar
              Row(
                children: [
                  SizedBox(
                    width: 36,
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
                        value: pct / 100.0,
                        minHeight: 8,
                        backgroundColor: barColor.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(barColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isHarmful
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                    color: barColor,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _localizedImpactSummary(score, l10n),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              if (score.sampleCount < 10)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.impactDataPoints(score.sampleCount),
                    style: TextStyle(
                        fontSize: 10, color: Colors.orange[700]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizedImpactSummary(ImpactScore score, AppLocalizations l10n) {
  if (score.sampleCount < 3) return l10n.impactNotEnoughData;
  final pct = score.correlationPercent;
  final direction =
      score.isHarmful ? l10n.impactDrop : l10n.impactImprovement;
  final lag = score.bestLagHours == 1
      ? l10n.impactOneHour
      : l10n.impactHours(score.bestLagHours);
  return l10n.impactSummary(pct, direction, lag);
}
