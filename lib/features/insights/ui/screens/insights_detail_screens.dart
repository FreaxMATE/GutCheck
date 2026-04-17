import 'package:flutter/material.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../widgets/time_filter_bar.dart';
import 'insights_screen.dart';

class _InsightsDetailScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _InsightsDetailScaffold({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TimeFilterBar(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: InsightsMetricToggleBar(),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class InsightsCalendarScreen extends StatelessWidget {
  const InsightsCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InsightsDetailScaffold(
      title: l10n.insightsTabCalendar,
      child: const InsightsCalendarView(),
    );
  }
}

class InsightsHeatmapScreen extends StatelessWidget {
  const InsightsHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InsightsDetailScaffold(
      title: l10n.insightsTabHeatmap,
      child: const InsightsHeatmapView(),
    );
  }
}

class InsightsImpactScreen extends StatelessWidget {
  const InsightsImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InsightsDetailScaffold(
      title: l10n.insightsTabImpact,
      child: const InsightsImpactView(),
    );
  }
}

class InsightsFingerprintScreen extends StatelessWidget {
  const InsightsFingerprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InsightsDetailScaffold(
      title: l10n.insightsTabFingerprint,
      child: const InsightsFingerprintView(),
    );
  }
}

class InsightsScatterScreen extends StatelessWidget {
  const InsightsScatterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InsightsDetailScaffold(
      title: l10n.insightsTabScatter,
      child: const InsightsScatterView(),
    );
  }
}
