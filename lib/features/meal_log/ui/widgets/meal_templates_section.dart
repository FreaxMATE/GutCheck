import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../data/models/meal_template.dart';
import '../../providers/meal_template_providers.dart';
import '../screens/edit_template_sheet.dart';

class MealTemplatesSection extends ConsumerWidget {
  final void Function(MealTemplate template) onApplyTemplate;

  const MealTemplatesSection({super.key, required this.onApplyTemplate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(mealTemplateProvider);

    return templatesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (templates) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                l10n.mealTemplatesTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: templates.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _NewTemplateCard(
                      onTap: () => _openNewTemplate(context, ref),
                    );
                  }
                  final template = templates[index - 1];
                  return _TemplateCard(
                    template: template,
                    onTap: () => onApplyTemplate(template),
                    onLongPress: () =>
                        _showTemplateOptions(context, ref, template, l10n),
                  );
                },
              ),
            ),
            if (templates.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.mealTemplatesEmpty,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  void _openNewTemplate(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const EditTemplateSheet(),
    ).then((_) => ref.invalidate(mealTemplateProvider));
  }

  void _showTemplateOptions(BuildContext context, WidgetRef ref,
      MealTemplate template, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.mealTemplateEditTitle),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) =>
                      EditTemplateSheet(initialTemplate: template),
                ).then((_) => ref.invalidate(mealTemplateProvider));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(l10n.mealTemplateDeleteTitle,
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, template, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref,
      MealTemplate template, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mealTemplateDeleteTitle),
        content: Text(l10n.mealTemplateDeleteContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(mealTemplateProvider.notifier).deleteTemplate(template.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mealTemplateDeleted)),
        );
      }
    }
  }
}

// ── New template card ────────────────────────────────────────────────────────

class _NewTemplateCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NewTemplateCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 110,
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 4),
                  Text(
                    l10n.mealTemplateNew,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Template card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final MealTemplate template;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 150,
        child: Card(
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bookmark_rounded, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          template.name,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (template.mealLabel != null)
                    Text(
                      localizedMealLabel(template.mealLabel, l10n),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  const Spacer(),
                  Text(
                    l10n.mealTemplateIngredientCount(
                        template.ingredients.length),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
