import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/constants/food_categories.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../data/models/ingredient.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;
  final Widget? trailing;

  const IngredientTile({
    super.key,
    required this.ingredient,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final cat = ingredient.category;
    final fodmap = ingredient.fodmapLevel;

    return ListTile(
      onTap: onTap,
      leading: Hero(
        tag: 'ingredient-avatar-${ingredient.id}',
        flightShuttleBuilder: (_, animation, __, ___, ____) {
          // Transparent material during flight so the chip is cleanly drawn
          // on top of the rising sheet.
          return Material(
            type: MaterialType.transparency,
            child: CircleAvatar(
              backgroundColor: cat.color.withValues(alpha: 0.15),
              child: Icon(cat.icon, color: cat.color, size: 20),
            ),
          );
        },
        child: CircleAvatar(
          backgroundColor: cat.color.withValues(alpha: 0.15),
          child: Icon(cat.icon, color: cat.color, size: 20),
        ),
      ),
      title: Text(ingredient.localizedName(locale)),
      subtitle: Row(
        children: [
          _CategoryChip(cat),
          const SizedBox(width: 6),
          _FodmapBadge(fodmap),
        ],
      ),
      trailing: trailing,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final FoodCategory category;
  const _CategoryChip(this.category);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.localizedName(l10n),
        style: TextStyle(
          fontSize: 11,
          color: category.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FodmapBadge extends StatelessWidget {
  final String level;
  const _FodmapBadge(this.level);

  Color get _color {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${level.toUpperCase()} FODMAP',
        style: TextStyle(
          fontSize: 10,
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
