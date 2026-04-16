import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/wellness_entry.dart';
import '../../providers/wellness_providers.dart';
import '../widgets/edit_wellness_sheet.dart';

class WellnessHistoryScreen extends ConsumerWidget {
  const WellnessHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(wellnessAllHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wellnessHistoryTitle)),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError(e))),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PulseIcon(
                      icon: Icons.sentiment_satisfied_alt_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text(l10n.wellnessHistoryEmpty,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          final items = _buildItems(entries);
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
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
              final entry = item as WellnessEntry;
              return StaggeredEntrance(
                index: i,
                baseDelay: const Duration(milliseconds: 25),
                child: _WellnessEntryTile(
                  entry: entry,
                  onEdit: () => _editEntry(ctx, ref, entry),
                  onDelete: () => _confirmDelete(ctx, ref, entry.id, l10n),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static List<Object> _buildItems(List<WellnessEntry> entries) {
    final items = <Object>[];
    DateTime? lastDay;
    for (final entry in entries) {
      final day = DateTime(
        entry.recordedAt.year,
        entry.recordedAt.month,
        entry.recordedAt.day,
      );
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(entry);
    }
    return items;
  }

  void _editEntry(BuildContext context, WidgetRef ref, WellnessEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditWellnessSheet(entry: entry),
    ).then((_) => ref.invalidate(wellnessAllHistoryProvider));
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, int id, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctxL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxL10n.wellnessDeleteTitle),
          content: Text(ctxL10n.wellnessDeleteContent),
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
      await ref.read(wellnessHistoryNotifierProvider.notifier).deleteEntry(id);
      ref.invalidate(wellnessAllHistoryProvider);
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
    final today = DateTime(now.year, now.month, now.day) == date;
    final yesterday = DateTime(now.year, now.month, now.day - 1) == date;
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

// ── Entry tile ────────────────────────────────────────────────────────────────

class _WellnessEntryTile extends StatelessWidget {
  final WellnessEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WellnessEntryTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Show discomfort 0-10 (the actual gutPeace value).
    final d = entry.gutPeace.clamp(0, 10);
    // Color: 0-2 green, 3-5 orange, 6+ red.
    final badgeColor = d <= 2
        ? Colors.green
        : d <= 5
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discomfort badge (0-10)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$d',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: badgeColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(GutDateUtils.formatTime(entry.recordedAt),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _SliderBadge(
                        icon: Icons.medical_information_outlined,
                        color: Colors.red,
                        value: entry.gutPeace,
                        min: 0,
                        max: 10,
                        tooltip: 'Gut discomfort',
                        inverted: true, // high value = bad (red)
                      ),
                      const SizedBox(width: 4),
                      _SliderBadge(
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orange,
                        value: entry.heartburn,
                        max: 10,
                        tooltip: 'Heartburn',
                        inverted: true,
                      ),
                    ],
                  ),
                  if (entry.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.notes!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: Colors.red,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final int min;
  final int max;
  final String tooltip;
  final bool inverted;

  const _SliderBadge({
    required this.icon,
    required this.color,
    required this.value,
    required this.max,
    required this.tooltip,
    this.min = 1,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final range = (max - min).clamp(1, 1000);
    final t = ((value - min) / range).clamp(0.0, 1.0);
    final badgeColor = inverted
        ? Color.lerp(Colors.green, Colors.red, t)!
        : Color.lerp(Colors.red, Colors.green, t)!;

    return Tooltip(
      message: '$tooltip: $value/$max',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 2),
          Text('$value',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: badgeColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
