import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/shake_detector.dart';
import '../../data/models/meal_entry.dart';
import '../../data/models/meal_ingredient.dart';
import '../../data/models/meal_template.dart';
import '../../providers/meal_providers.dart';
import '../../providers/meal_template_providers.dart';
import '../screens/edit_template_sheet.dart';
import '../widgets/meal_entry_tile.dart';
import '../widgets/meal_templates_section.dart';
import 'log_meal_sheet.dart';

class MealLogScreen extends ConsumerStatefulWidget {
  const MealLogScreen({super.key});

  @override
  ConsumerState<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends ConsumerState<MealLogScreen> {
  final _scrollController = ScrollController();
  late final ShakeDetector _shake = ShakeDetector(onShake: _onShake);

  @override
  void initState() {
    super.initState();
    _shake.start();
  }

  @override
  void dispose() {
    _shake.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _onShake() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.shakeTip),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Approximate day-jump: scroll by ~one day-section worth of pixels.
  void _jumpDay({required bool forward}) {
    if (!_scrollController.hasClients) return;
    const dayHeight = 220.0;
    final current = _scrollController.offset;
    final maxOffset = _scrollController.position.maxScrollExtent;
    final target = forward
        ? (current + dayHeight).clamp(0.0, maxOffset)
        : (current - dayHeight).clamp(0.0, maxOffset);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(mealHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mealLogTitle),
            Text(
              GutDateUtils.formatDay(DateTime.now()),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError(e))),
        data: (entries) {
          // Build a flat list of (date-header | meal-entry) items
          final items = _buildItems(entries);

          return Column(
            children: [
              // Templates section (always visible)
              MealTemplatesSection(
                onApplyTemplate: (template) =>
                    _applyTemplate(context, ref, template),
              ),

              // Meal history
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PulseIcon(
                                icon: Icons.restaurant_rounded, size: 64),
                            const SizedBox(height: 16),
                            Text(l10n.mealLogEmpty,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              l10n.mealLogEmptyHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragEnd: (d) {
                          final vx = d.primaryVelocity ?? 0;
                          if (vx.abs() < 400) return;
                          // Swipe right → go to more recent (scroll up)
                          // Swipe left  → go to older (scroll down)
                          _jumpDay(forward: vx < 0);
                        },
                        child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) {
                          final item = items[i];
                          if (item is DateTime) {
                            return StaggeredEntrance(
                              index: i,
                              baseDelay: const Duration(milliseconds: 25),
                              child: _DateHeader(date: item),
                            );
                          }
                          final entry = item as MealEntry;
                          return StaggeredEntrance(
                            index: i,
                            baseDelay: const Duration(milliseconds: 25),
                            child: MealEntryTile(
                              entry: entry,
                              onEdit: () => _editMeal(ctx, ref, entry),
                              onDelete: () =>
                                  _confirmDelete(ctx, ref, entry.id, l10n),
                              onSaveAsTemplate: () =>
                                  _saveAsTemplate(ctx, ref, entry),
                            ),
                          );
                        },
                      )),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _logMeal(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.mealLogButton),
      ),
    );
  }

  /// Groups entries by day, returns a flat list alternating
  /// [DateTime] (day header) and [MealEntry] items.
  static List<Object> _buildItems(List<MealEntry> entries) {
    final items = <Object>[];
    DateTime? lastDay;
    for (final entry in entries) {
      final day = DateTime(
        entry.consumedAt.year,
        entry.consumedAt.month,
        entry.consumedAt.day,
      );
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(entry);
    }
    return items;
  }

  void _logMeal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const LogMealSheet(),
    ).then((_) => ref.invalidate(mealHistoryProvider));
  }

  void _applyTemplate(
      BuildContext context, WidgetRef ref, MealTemplate template) {
    // Build a prefill MealEntry from the template
    final prefill = MealEntry()
      ..mealLabel = template.mealLabel
      ..consumedAt = DateTime.now()
      ..ingredients = template.ingredients
          .map((i) => MealIngredient()
            ..ingredientId = i.ingredientId
            ..ingredientName = i.ingredientName
            ..quantity = i.quantity)
          .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          LogMealSheet(initialEntry: prefill, isNewFromTemplate: true),
    ).then((_) => ref.invalidate(mealHistoryProvider));
  }

  void _saveAsTemplate(
      BuildContext context, WidgetRef ref, MealEntry entry) {
    final prefill = MealTemplate()
      ..name = ''
      ..mealLabel = entry.mealLabel
      ..ingredients = entry.ingredients
          .map((i) => MealIngredient()
            ..ingredientId = i.ingredientId
            ..ingredientName = i.ingredientName
            ..quantity = i.quantity)
          .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditTemplateSheet(initialTemplate: prefill),
    ).then((_) => ref.invalidate(mealTemplateProvider));
  }

  void _editMeal(BuildContext context, WidgetRef ref, MealEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => LogMealSheet(initialEntry: entry),
    ).then((_) => ref.invalidate(mealHistoryProvider));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id,
      AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctxL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxL10n.mealDeleteTitle),
          content: Text(ctxL10n.mealDeleteContent),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctxL10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctxL10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(mealLogProvider.notifier).deleteMeal(id);
      ref.invalidate(mealHistoryProvider);
    }
  }
}

// ── Date header ───────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day) == date;
    final yesterday =
        DateTime(now.year, now.month, now.day - 1) == date;

    final label = today
        ? 'Today · ${GutDateUtils.formatDay(date)}'
        : yesterday
            ? 'Yesterday · ${GutDateUtils.formatDay(date)}'
            : GutDateUtils.formatDay(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: today
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
