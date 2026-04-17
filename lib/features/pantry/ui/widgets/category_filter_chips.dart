import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/constants/food_categories.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../providers/pantry_providers.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(pantryCategoryFilterProvider);
    final customOnly = ref.watch(pantryCustomOnlyProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: const Icon(Icons.person, size: 16),
              label: Text(l10n.pantryMyFoods),
              selected: customOnly,
              onSelected: (_) =>
                  ref.read(pantryCustomOnlyProvider.notifier).state =
                      !customOnly,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(l10n.categoryAll),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(pantryCategoryFilterProvider.notifier).state = null,
            ),
          ),
          ...FoodCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(cat.icon, size: 16, color: cat.color),
                label: Text(cat.localizedName(l10n)),
                selected: selected == cat,
                selectedColor: cat.color.withOpacity(0.2),
                checkmarkColor: cat.color,
                onSelected: (_) =>
                    ref.read(pantryCategoryFilterProvider.notifier).state =
                        selected == cat ? null : cat,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
