import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/utils/error_dialog.dart';
import '../../../achievements/achievements.dart';
import '../../../home/ui/widgets/gut_buddy.dart';
import '../../providers/wellness_providers.dart';
import '../widgets/diarrhea_toggle.dart';
import '../widgets/gi_symptom_slider.dart';
import '../widgets/linked_meal_selector.dart';
import '../widgets/wellness_score_ring.dart';

class WellnessCheckScreen extends ConsumerWidget {
  const WellnessCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(wellnessDraftProvider);
    final notifier = ref.read(wellnessDraftProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wellnessTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.wellnessHistoryTitle,
            onPressed: () => context.push('/wellness/history'),
          ),
          TextButton.icon(
            onPressed: () => _submit(context, ref),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live score ring + Gut Buddy side-by-side
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GutBuddy(size: 110, discomfort: draft.gutPeace.round()),
                const SizedBox(width: 12),
                WellnessScoreRing(
                  discomfort: draft.gutPeace.round(),
                  size: 120,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _discomfortLabel(draft.gutPeace.round(), l10n),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              l10n.wellnessGutPeace,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Divider(),

            GiSymptomSlider(
              label: l10n.wellnessGutPeace,
              minLabel: l10n.wellnessGutPeaceMin,
              maxLabel: l10n.wellnessGutPeaceMax,
              value: draft.gutPeace,
              inverted: true,
              onChanged: notifier.setGutPeace,
            ),

            const SizedBox(height: 16),

            GiSymptomSlider(
              label: l10n.wellnessHeartburn,
              minLabel: l10n.wellnessHeartburnMin,
              maxLabel: l10n.wellnessHeartburnMax,
              value: draft.heartburn,
              inverted: true,
              onChanged: notifier.setHeartburn,
            ),

            const SizedBox(height: 16),

            GiSymptomSlider(
              label: l10n.wellnessStress,
              minLabel: l10n.wellnessStressMin,
              maxLabel: l10n.wellnessStressMax,
              value: draft.stress,
              inverted: true,
              onChanged: notifier.setStress,
            ),

            const SizedBox(height: 16),
            DiarrheaToggle(
              value: draft.diarrhea,
              label: l10n.wellnessDiarrhea,
              onChanged: notifier.setDiarrhea,
            ),

            const SizedBox(height: 24),

            Text(
              l10n.wellnessLinkMealsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.wellnessLinkMealsHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const LinkedMealSelector(),

            const SizedBox(height: 24),

            TextField(
              decoration: InputDecoration(
                labelText: l10n.wellnessNotesLabel,
                hintText: l10n.wellnessNotesHint,
                prefixIcon: const Icon(Icons.note_outlined),
              ),
              maxLines: 3,
              onChanged: notifier.setNotes,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _submit(context, ref),
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.wellnessSaveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps 0-10 discomfort to a localized label.
  String _discomfortLabel(int d, AppLocalizations l10n) {
    if (d <= 1) return l10n.wellnessScoreGreat;
    if (d <= 3) return l10n.wellnessScoreOkay;
    if (d <= 5) return l10n.wellnessSomeDiscomfort;
    if (d <= 7) return l10n.wellnessSignificantSymptoms;
    return l10n.wellnessSevereDiscomfort;
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(wellnessDraftProvider.notifier).submit();
      if (context.mounted) {
        // Fire-and-forget — burst auto-removes. SnackBar shows immediately.
        unawaited(showSuccessBurst(context));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.wellnessSaved)));
      }
      // Evaluate achievements — any newly unlocked show a toast.
      final newlyUnlocked = await evaluateAchievements(ref);
      for (final a in newlyUnlocked) {
        if (!context.mounted) break;
        showAchievementToast(context, a);
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }
    } catch (e, st) {
      debugPrint('Wellness save failed: $e\n$st');
      if (context.mounted) {
        await showErrorDialog(context, e, st);
      }
    }
  }
}
