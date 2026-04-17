import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../insights/ui/widgets/symptom_timeline.dart';
import '../../../meal_log/data/models/meal_entry.dart';
import '../../../wellness/data/models/wellness_entry.dart';

/// Shows the last 3 days as symptom timelines on the home screen.
class SymptomTimelineCard extends ConsumerWidget {
  const SymptomTimelineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<_TimelineData>(
      future: _load(ref),
      builder: (ctx, snap) {
        final data = snap.data;
        if (data == null || data.days.isEmpty) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timeline_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Symptom Timeline',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final day in data.days) ...[
                  SymptomTimeline(
                    date: day.date,
                    meals: day.meals,
                    wellness: day.wellness,
                  ),
                  if (day != data.days.last)
                    const Divider(indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_TimelineData> _load(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);
    final now = DateTime.now();
    final days = <_DayData>[];

    for (int i = 0; i < 3; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDay = date.add(const Duration(days: 1));
      final meals = await db.mealsInRange(from: date, to: nextDay);
      final wellness = await db.wellnessInRange(from: date, to: nextDay);
      if (meals.isNotEmpty || wellness.isNotEmpty) {
        days.add(_DayData(date: date, meals: meals, wellness: wellness));
      }
    }

    return _TimelineData(days: days);
  }
}

class _TimelineData {
  final List<_DayData> days;
  _TimelineData({required this.days});
}

class _DayData {
  final DateTime date;
  final List<MealEntry> meals;
  final List<WellnessEntry> wellness;
  _DayData({required this.date, required this.meals, required this.wellness});
}
