import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

/// Slider for a GI symptom or context variable (stress, discomfort, etc.).
///
/// Displays values 0.0-10.0 in 0.5 steps. Internally the caller can store
/// the value however they wish; this widget deals purely in display doubles.
///
/// [inverted] controls color semantics only:
///   - false → high value is GOOD (slider turns greener as value rises).
///   - true  → high value is BAD  (slider turns redder as value rises).
class GiSymptomSlider extends StatelessWidget {
  final String label;
  final String minLabel;
  final String maxLabel;
  final double value; // 0.0 - 10.0
  final bool inverted;
  final ValueChanged<double> onChanged;

  const GiSymptomSlider({
    super.key,
    required this.label,
    required this.minLabel,
    required this.maxLabel,
    required this.value,
    required this.onChanged,
    this.inverted = false,
  });

  Color get _thumbColor {
    final t = (value / 10.0).clamp(0.0, 1.0);
    final goodness = inverted ? (1.0 - t) : t;
    return AppColors.wellnessScoreInterpolated(goodness * 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = value.clamp(0.0, 10.0);

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
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: _thumbColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  displayValue == displayValue.roundToDouble()
                      ? '${displayValue.round()}'
                      : displayValue.toStringAsFixed(1),
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
              value: displayValue,
              min: 0,
              max: 10,
              divisions: 20, // 0.5 steps
              onChanged: (v) {
                // Round to nearest 0.5
                final rounded = (v * 2).round() / 2.0;
                if (rounded != value) {
                  final t = (rounded / 10.0).clamp(0.0, 1.0);
                  final severity = inverted ? t : (1.0 - t);
                  if (severity > 0.8) {
                    HapticFeedback.heavyImpact();
                  } else if (severity > 0.5) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.selectionClick();
                  }
                }
                onChanged(rounded);
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
