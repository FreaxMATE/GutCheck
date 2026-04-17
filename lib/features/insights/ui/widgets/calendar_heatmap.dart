import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class CalendarHeatmap extends ConsumerWidget {
  final Map<DateTime, double> dailyScores;
  final DateTime month;
  final ValueChanged<DateTime>? onDayTap;

  const CalendarHeatmap({
    super.key,
    required this.dailyScores,
    required this.month,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animate = ref.watch(animationsEnabledProvider);
    final days = GutDateUtils.daysInMonth(month);
    final firstDayOfWeek = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = firstDayOfWeek + days.length;
    final rows = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            GutDateUtils.formatMonth(month),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // Weekday labels
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        // Day grid
        ...List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cell = row * 7 + col;
              final dayIndex = cell - firstDayOfWeek;
              if (dayIndex < 0 || dayIndex >= days.length) {
                return const Expanded(child: SizedBox(height: 36));
              }
              final day = days[dayIndex];
              final score = dailyScores[DateTime(day.year, day.month, day.day)];
              final cellWidget = Container(
                margin: const EdgeInsets.all(2),
                height: 36,
                decoration: BoxDecoration(
                  color: score != null
                      ? AppColors.wellnessScoreInterpolated(
                          score,
                        ).withValues(alpha: 0.7)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: score != null ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              );
              return Expanded(
                child: GestureDetector(
                  onTap: onDayTap != null ? () => onDayTap!(day) : null,
                  child: animate
                      ? _CellFadeIn(index: dayIndex, child: cellWidget)
                      : cellWidget,
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context)!.heatmapLegendPoor,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (i) {
              final score = (i + 1) * 20.0;
              return Container(
                width: 16,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.wellnessScoreInterpolated(
                    score,
                  ).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.heatmapLegendGreat,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class _CellFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  const _CellFadeIn({required this.index, required this.child});

  @override
  State<_CellFadeIn> createState() => _CellFadeInState();
}

class _CellFadeInState extends State<_CellFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 12 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.6,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
        child: widget.child,
      ),
    );
  }
}
