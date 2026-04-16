import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database_provider.dart';
import '../utils/error_dialog.dart';

/// Hidden diagnostics screen. Reachable only by tapping the version row in
/// Settings 5 times. Useful when investigating issues with real user data.
class DevScreen extends ConsumerWidget {
  const DevScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Dev tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Database'),
          FutureBuilder(
            future: _counts(ref),
            builder: (ctx, snap) {
              final data = snap.data;
              if (data == null) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [
                  _KVTile('Ingredients', '${data.ingredients}'),
                  _KVTile('Meal entries', '${data.meals}'),
                  _KVTile('Wellness entries', '${data.wellness}'),
                  _KVTile('Meal templates', '${data.templates}'),
                ],
              );
            },
          ),
          const Divider(),
          const _SectionHeader('Raw dumps'),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Dump last wellness entry'),
            onTap: () => _dumpLastWellness(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: const Text('Dump last meal entry'),
            onTap: () => _dumpLastMeal(context, ref),
          ),
          const Divider(),
          const _SectionHeader('Build info'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Flutter 3.41.6 · Dart 3.11.0'),
            subtitle: Text('Isar 3.1.0+1 · local-first'),
          ),
        ],
      ),
    );
  }

  Future<_DbCounts> _counts(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);
    final ings = await db.allCustomIngredients();
    final meals = await db.allMeals();
    final wellness = await db.allWellness();
    final templates = await db.allMealTemplates();
    return _DbCounts(
      ingredients: ings.length,
      meals: meals.length,
      wellness: wellness.length,
      templates: templates.length,
    );
  }

  Future<void> _dumpLastWellness(BuildContext ctx, WidgetRef ref) async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final all = await db.allWellness();
      final latest = all.isEmpty ? null : all.last;
      if (!ctx.mounted) return;
      if (latest == null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('No wellness entries')),
        );
        return;
      }
      await showErrorDialog(
        ctx,
        const JsonEncoder.withIndent('  ').convert({
          'id': latest.id,
          'recordedAt': latest.recordedAt.toIso8601String(),
          'gutPeace': latest.gutPeace,
          'heartburn': latest.heartburn,
          'diarrhea': latest.diarrhea,
          'wellnessScore': latest.wellnessScore,
          'linkedMealIds': latest.linkedMealIds,
          'notes': latest.notes,
          'isSample': latest.isSample,
        }),
      );
    } catch (e, st) {
      if (ctx.mounted) await showErrorDialog(ctx, e, st);
    }
  }

  Future<void> _dumpLastMeal(BuildContext ctx, WidgetRef ref) async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final all = await db.allMeals();
      final latest = all.isEmpty ? null : all.last;
      if (!ctx.mounted) return;
      if (latest == null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('No meal entries')),
        );
        return;
      }
      await showErrorDialog(
        ctx,
        const JsonEncoder.withIndent('  ').convert({
          'id': latest.id,
          'consumedAt': latest.consumedAt.toIso8601String(),
          'mealLabel': latest.mealLabel,
          'ingredients': latest.ingredients
              .map((i) => {
                    'id': i.ingredientId,
                    'name': i.ingredientName,
                    'quantity': i.quantity,
                  })
              .toList(),
          'notes': latest.notes,
        }),
      );
    } catch (e, st) {
      if (ctx.mounted) await showErrorDialog(ctx, e, st);
    }
  }
}

class _DbCounts {
  final int ingredients, meals, wellness, templates;
  _DbCounts({
    required this.ingredients,
    required this.meals,
    required this.wellness,
    required this.templates,
  });
}

class _KVTile extends StatelessWidget {
  final String k;
  final String v;
  const _KVTile(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(k),
      trailing: Text(v,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
      dense: true,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
