import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../providers/home_providers.dart';
import 'gut_buddy.dart';

/// Shows a fun, time-aware greeting plus a rotating supportive message.
///
/// The greeting is picked randomly each build (fresh every time you open the
/// app — keeps it playful). The supportive message rotates by day so it stays
/// stable within a single session.
class GreetingBanner extends ConsumerWidget {
  const GreetingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final greeting = _randomGreeting(now, l10n);
    final message = _messageForDay(now, l10n);
    final latestWellness = ref.watch(lastWellnessProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GutBuddy(
            size: 72,
            discomfort: latestWellness.maybeWhen(
              data: (w) => w?.gutPeaceDisplay.round(),
              orElse: () => null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _randomGreeting(DateTime now, AppLocalizations l10n) {
    final h = now.hour;
    final List<String> pool;
    if (h < 11) {
      pool = [
        l10n.greetingMorning1,
        l10n.greetingMorning2,
        l10n.greetingMorning3,
        l10n.greetingMorning4,
        l10n.greetingMorning5,
        l10n.greetingMorning6,
        l10n.greetingMorning7,
        l10n.greetingMorning8,
      ];
    } else if (h < 17) {
      pool = [
        l10n.greetingAfternoon1,
        l10n.greetingAfternoon2,
        l10n.greetingAfternoon3,
        l10n.greetingAfternoon4,
        l10n.greetingAfternoon5,
        l10n.greetingAfternoon6,
        l10n.greetingAfternoon7,
      ];
    } else if (h < 22) {
      pool = [
        l10n.greetingEvening1,
        l10n.greetingEvening2,
        l10n.greetingEvening3,
        l10n.greetingEvening4,
        l10n.greetingEvening5,
        l10n.greetingEvening6,
      ];
    } else {
      pool = [
        l10n.greetingNight1,
        l10n.greetingNight2,
        l10n.greetingNight3,
        l10n.greetingNight4,
        l10n.greetingNight5,
      ];
    }
    return pool[Random().nextInt(pool.length)];
  }

  String _messageForDay(DateTime now, AppLocalizations l10n) {
    final messages = <String>[
      l10n.supportiveMsg1,
      l10n.supportiveMsg2,
      l10n.supportiveMsg3,
      l10n.supportiveMsg4,
      l10n.supportiveMsg5,
      l10n.supportiveMsg6,
      l10n.supportiveMsg7,
      l10n.supportiveMsg8,
      l10n.supportiveMsg9,
      l10n.supportiveMsg10,
    ];
    final seed = now.year * 10000 + now.month * 100 + now.day;
    return messages[Random(seed).nextInt(messages.length)];
  }
}
