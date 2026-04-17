import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pantry/providers/pantry_providers.dart';
import '../../data/models/meal_ingredient.dart';

class MealIngredientChip extends ConsumerWidget {
  final MealIngredient item;
  final VoidCallback? onDelete;

  const MealIngredientChip({super.key, required this.item, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    // Look up the ingredient to resolve its localized name.
    // Falls back to the denormalized name if the ingredient has been deleted.
    final ingredientAsync = ref.watch(
      singleIngredientProvider(item.ingredientId),
    );
    final displayName = ingredientAsync.maybeWhen(
      data: (ing) => ing?.localizedName(locale) ?? item.ingredientName,
      orElse: () => item.ingredientName,
    );

    return Chip(
      label: Text(
        item.quantity != null ? '$displayName (${item.quantity})' : displayName,
        style: const TextStyle(fontSize: 12),
      ),
      onDeleted: onDelete,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
