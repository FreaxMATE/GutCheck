import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

/// Slider for a GI symptom (or overall gut comfort).
///
/// [inverted] controls color semantics only:
///   - false → high value is GOOD (slider turns greener as value rises).
///   - true  → high value is BAD  (slider turns redder as value rises).
class GiSymptomSlider extends StatelessWidget {
  final String label;
  final String minLabel;
  final String maxLabel;
  final int value;
  final int min;
  final int max;
  final bool inverted;
  final ValueChanged<int> onChanged;

  const GiSymptomSlider({
    super.key,
    required this.label,
    required this.minLabel,
    required this.maxLabel,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.inverted = false,
  });

  Color get _thumbColor {
    final range = max - min;
    if (range <= 0) return AppColors.wellnessGreen;
    final normalized = (value - min) / range; // 0..1
    final goodness = inverted ? (1.0 - normalized) : normalized; // 0..1
    return AppColors.wellnessScoreInterpolated(goodness * 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisions = (max - min).clamp(1, 1000);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: theme.textTheme.titleSmall),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _thumbColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: _thumbColor),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _thumbColor,
              thumbColor: _thumbColor,
              inactiveTrackColor: _thumbColor.withValues(alpha: 0.2),
              overlayColor: _thumbColor.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              onChanged: (v) {
                final r = v.round();
                if (r != value) {
                  // Haptic intensity matches severity — stronger the
                  // closer we are to the bad end of the scale.
                  final range = (max - min).clamp(1, 1000);
                  final t = ((r - min) / range).clamp(0.0, 1.0);
                  final severity = inverted ? t : (1.0 - t);
                  if (severity > 0.8) {
                    HapticFeedback.heavyImpact();
                  } else if (severity > 0.5) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.selectionClick();
                  }
                }
                onChanged(r);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minLabel,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
                Text(maxLabel,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
