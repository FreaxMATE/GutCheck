import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../providers/insights_providers.dart';

class TimeFilterBar extends ConsumerWidget {
  const TimeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(insightsTimeFilterProvider);

    return SegmentedButton<TimeFilter>(
      segments: TimeFilter.values
          .map(
            (f) => ButtonSegment(value: f, label: Text(f.localizedLabel(l10n))),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (s) =>
          ref.read(insightsTimeFilterProvider.notifier).state = s.first,
    );
  }
}
