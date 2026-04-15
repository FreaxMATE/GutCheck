import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../providers/pantry_providers.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/ingredient_tile.dart';

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final searchQuery = ref.watch(pantrySearchQueryProvider);
    final ingredients = ref.watch(pagedIngredientsProvider);
    final dbReady = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pantryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: dbReady.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.databaseError(e))),
        data: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SearchBar(
                hintText: l10n.pantrySearchHint,
                leading: const Icon(Icons.search),
                trailing: searchQuery.isNotEmpty
                    ? [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ref
                              .read(pantrySearchQueryProvider.notifier)
                              .state = '',
                        )
                      ]
                    : null,
                onChanged: (v) =>
                    ref.read(pantrySearchQueryProvider.notifier).state = v,
              ),
            ),
            const CategoryFilterChips(),
            const SizedBox(height: 4),
            Expanded(
              child: ingredients.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(l10n.genericError(e))),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PulseIcon(
                              icon: Icons.search_off_rounded, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            searchQuery.isNotEmpty
                                ? l10n.pantryNoResults(searchQuery)
                                : l10n.pantryEmpty,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => IngredientTile(
                      ingredient: items[i],
                      onTap: () => _showIngredientDetail(ctx, ref, items[i].id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pantry/add-food'),
        icon: const Icon(Icons.add),
        label: Text(l10n.pantryAddFood),
      ),
    );
  }

  void _showIngredientDetail(
      BuildContext context, WidgetRef ref, int id) async {
    final db = await ref.read(appDatabaseProvider.future);
    final ingredient = await db.findIngredientById(id);
    if (ingredient == null || !context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, controller) {
          final sheetL10n = AppLocalizations.of(ctx)!;
          final locale = Localizations.localeOf(ctx).languageCode;
          return ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        ingredient.category.color.withOpacity(0.15),
                    child: Icon(ingredient.category.icon,
                        color: ingredient.category.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ingredient.localizedName(locale),
                            style:
                                Theme.of(ctx).textTheme.headlineSmall),
                        Text(ingredient.category.localizedName(sheetL10n),
                            style: TextStyle(
                                color: ingredient.category.color,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (!ingredient.isSeeded)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      tooltip: sheetL10n.delete,
                      onPressed: () =>
                          _confirmDeleteIngredient(ctx, ref, ingredient.id,
                              ingredient.localizedName(locale)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(sheetL10n.pantryFodmapLevel,
                  ingredient.fodmapLevel.toUpperCase()),
              if (ingredient.secondaryCategory != null)
                _DetailRow(sheetL10n.pantryAlsoClassifiedAs,
                    ingredient.secondaryCategory!.localizedName(sheetL10n)),
              if (ingredient.notes != null)
                _DetailRow(sheetL10n.pantryNotes, ingredient.notes!),
              if (!ingredient.isSeeded) ...[
                const SizedBox(height: 16),
                Chip(
                  label: Text(sheetL10n.pantryCustomFood),
                  avatar: const Icon(Icons.person, size: 16),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteIngredient(
      BuildContext sheetCtx, WidgetRef ref, int id, String displayName) async {
    final l10n = AppLocalizations.of(sheetCtx)!;
    final confirmed = await showDialog<bool>(
      context: sheetCtx,
      builder: (dialogCtx) {
        final dialogL10n = AppLocalizations.of(dialogCtx)!;
        return AlertDialog(
          title: Text(dialogL10n.pantryDeleteTitle),
          content: Text(dialogL10n.pantryDeleteContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(dialogL10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      final db = await ref.read(appDatabaseProvider.future);
      await db.deleteIngredient(id);
      ref.invalidate(pagedIngredientsProvider);
      ref.invalidate(singleIngredientProvider(id));
      ref.invalidate(ingredientCountProvider);

      if (sheetCtx.mounted) {
        Navigator.of(sheetCtx).pop(); // close the detail sheet
        ScaffoldMessenger.of(sheetCtx).showSnackBar(
          SnackBar(content: Text(l10n.pantryDeleted(displayName))),
        );
      }
    } catch (e) {
      if (sheetCtx.mounted) {
        ScaffoldMessenger.of(sheetCtx).showSnackBar(
          SnackBar(content: Text(l10n.genericError(e))),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
