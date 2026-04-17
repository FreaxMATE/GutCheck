import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/meal_entry.dart';
import 'meal_ingredient_chip.dart';

class MealEntryTile extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onSaveAsTemplate;

  const MealEntryTile({
    super.key,
    required this.entry,
    this.onDelete,
    this.onEdit,
    this.onSaveAsTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  localizedMealLabel(entry.mealLabel, l10n),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  GutDateUtils.formatTime(entry.consumedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                if (onSaveAsTemplate != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                    onPressed: onSaveAsTemplate,
                    tooltip: l10n.mealTemplateSaveAs,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                if (onDelete != null) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Colors.red,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            if (entry.ingredients.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: entry.ingredients
                    .map((i) => MealIngredientChip(item: i))
                    .toList(),
              ),
            ],
            if (entry.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                entry.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
