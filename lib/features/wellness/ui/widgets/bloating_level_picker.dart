import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';

/// Compact 3-level selector for bloating (0=Keine, 1=Leicht, 2=Stark).
/// Renders visually nested under the gut-discomfort slider: indented with
/// a thin accent line on the left and a smaller sublabel, signalling that
/// it's a refinement of the main discomfort reading.
class BloatingLevelPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const BloatingLevelPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labels = [
      l10n.bloatingLevelNone,
      l10n.bloatingLevelLight,
      l10n.bloatingLevelStrong,
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      child: Row(
        children: [
          // Accent rail indicating this field nests under the one above.
          Container(
            width: 3,
            height: 52,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.wellnessBloating,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                SegmentedButton<int>(
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: WidgetStatePropertyAll(
                      theme.textTheme.labelMedium,
                    ),
                  ),
                  showSelectedIcon: false,
                  segments: [
                    for (int i = 0; i < 3; i++)
                      ButtonSegment(value: i, label: Text(labels[i])),
                  ],
                  selected: {value.clamp(0, 2)},
                  onSelectionChanged: (s) => onChanged(s.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
