import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:gutcheck/l10n/app_localizations.dart';
import '../animations/animations.dart';
import '../animations/theme_reveal.dart';
import '../database/app_database_provider.dart';
import '../database/isar_provider.dart';
import '../database/sample_data_service.dart';
import '../providers/locale_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/export_service.dart';

// Supported locales with display names (shown in their own language).
const _supportedLocales = [
  (code: null, label: null), // "System default" — label resolved from l10n
  (code: 'en', label: 'English'),
  (code: 'de', label: 'Deutsch'),
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sampleLoading = false;
  int _versionTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final dbAsync = ref.watch(appDatabaseProvider);

    String currentLocaleLabel() {
      if (currentLocale == null) return l10n.settingsLanguageAuto;
      return _supportedLocales
              .firstWhere((e) => e.code == currentLocale.languageCode,
                  orElse: () => (code: null, label: null))
              .label ??
          currentLocale.languageCode;
    }

    String currentThemeLabel() {
      switch (themeMode) {
        case ThemeMode.light:
          return l10n.settingsThemeLight;
        case ThemeMode.dark:
          return l10n.settingsThemeDark;
        case ThemeMode.system:
          return l10n.settingsThemeSystem;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          // ── Appearance ──────────────────────────────────────────────────────
          _SectionHeader(l10n.settingsSectionAppearance),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsThemeTitle),
            subtitle: Text(currentThemeLabel()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTheme(context, themeMode, l10n),
          ),

          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_rounded),
            title: Text(l10n.settingsAnimationsTitle),
            subtitle: Text(l10n.settingsAnimationsSubtitle),
            value: ref.watch(animationsEnabledProvider),
            onChanged: (v) =>
                ref.read(animationsEnabledProvider.notifier).setEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_rounded),
            title: Text(l10n.settingsSoundsTitle),
            subtitle: Text(l10n.settingsSoundsSubtitle),
            value: ref.watch(soundEnabledProvider),
            onChanged: (v) =>
                ref.read(soundEnabledProvider.notifier).setEnabled(v),
          ),

          // ── Language ────────────────────────────────────────────────────────
          _SectionHeader(l10n.settingsSectionLanguage),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.settingsSectionLanguage),
            subtitle: Text(currentLocaleLabel()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, currentLocale, l10n),
          ),

          // ── Data ────────────────────────────────────────────────────────────
          _SectionHeader(l10n.settingsSectionData),
          dbAsync.when(
            data: (db) {
              final sampleService = SampleDataService(db);
              return FutureBuilder<bool>(
                future: sampleService.hasSampleData(),
                builder: (ctx, snap) {
                  final hasSample = snap.data ?? false;
                  return SwitchListTile(
                    secondary: _sampleLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.science_outlined),
                    title: Text(l10n.settingsSampleDataTitle),
                    subtitle: Text(l10n.settingsSampleDataSubtitle),
                    value: hasSample,
                    onChanged: _sampleLoading
                        ? null
                        : (on) => _toggleSampleData(
                            context, sampleService, on, l10n),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) => const SizedBox.shrink(),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: Text(l10n.settingsExportTitle),
            subtitle: Text(l10n.settingsExportSubtitle),
            onTap: () => _export(context),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: Text(l10n.settingsImportTitle),
            subtitle: Text(l10n.settingsImportSubtitle),
            onTap: () => _import(context),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.kitchen_rounded),
            title: Text(l10n.settingsExportPantryTitle),
            subtitle: Text(l10n.settingsExportPantrySubtitle),
            onTap: () => _exportPantry(context),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart_rounded),
            title: Text(l10n.settingsImportPantryTitle),
            subtitle: Text(l10n.settingsImportPantrySubtitle),
            onTap: () => _importPantry(context),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading:
                const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: Text(l10n.settingsClearTitle,
                style: const TextStyle(color: Colors.red)),
            subtitle: Text(l10n.settingsClearSubtitle),
            onTap: () => _confirmClear(context, l10n),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.dangerous_outlined, color: Colors.red),
            title: Text(l10n.settingsResetDbTitle,
                style: const TextStyle(color: Colors.red)),
            subtitle: Text(l10n.settingsResetDbSubtitle),
            onTap: () => _confirmResetDatabase(context, l10n),
          ),

          // ── Achievements ────────────────────────────────────────────────────
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
            title: Text(l10n.settingsTrophiesTitle),
            subtitle: Text(l10n.settingsTrophiesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/trophies'),
          ),

          // ── About ────────────────────────────────────────────────────────────
          _SectionHeader(l10n.settingsSectionAbout),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('GutCheck'),
            subtitle: Text(l10n.settingsAppVersion),
            onTap: () {
              _versionTapCount++;
              if (_versionTapCount >= 5) {
                _versionTapCount = 0;
                context.push('/dev');
              } else if (_versionTapCount >= 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${5 - _versionTapCount} more tap(s) for dev mode…'),
                    duration: const Duration(milliseconds: 1200),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(l10n.settingsPrivacyTitle),
            subtitle: Text(l10n.settingsPrivacySubtitle),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTheme(
      BuildContext context, ThemeMode current, AppLocalizations l10n) async {
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (_) => _ThemeDialog(current: current),
    );
    if (picked == null || picked == current) return;
    if (!context.mounted) return;

    // Resolve what the *new* theme's background will be, then circular-reveal
    // from roughly where the theme tile sits.
    final scheme = MediaQuery.of(context).platformBrightness;
    final isDarkAfter = switch (picked) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => scheme == Brightness.dark,
    };
    final fill = isDarkAfter ? const Color(0xFF121212) : const Color(0xFFF7F7F7);
    final size = MediaQuery.of(context).size;
    final origin = Offset(size.width * 0.85, 120); // near the theme tile
    final enabled = ref.read(animationsEnabledProvider);
    if (enabled) {
      await showThemeReveal(
        context: context,
        origin: origin,
        color: fill,
        applyTheme: () =>
            ref.read(themeModeProvider.notifier).setThemeMode(picked),
      );
    } else {
      await ref.read(themeModeProvider.notifier).setThemeMode(picked);
    }
  }

  Future<void> _pickLanguage(
      BuildContext context, Locale? current, AppLocalizations l10n) async {
    final picked = await showDialog<String?>(
      context: context,
      builder: (_) => _LanguageDialog(current: current),
    );
    if (picked == null) return;
    await ref
        .read(localeProvider.notifier)
        .setLocale(picked == '_auto_' ? null : Locale(picked));
  }

  Future<void> _toggleSampleData(BuildContext context, SampleDataService svc,
      bool on, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sampleLoading = true);
    try {
      if (on) {
        await svc.insertSampleData();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsSampleDataAdded)),
        );
      } else {
        await svc.clearSampleData();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsSampleDataRemoved)),
        );
      }
    } finally {
      if (mounted) setState(() => _sampleLoading = false);
    }
  }

  Future<void> _export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ExportService.exportAll(ref);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportSuccess)),
      );
    } catch (e) {
      final errorMsg =
          e is ExportResult ? e.message : l10n.settingsExportError(e);
      messenger.showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  Future<void> _exportPantry(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ExportService.exportPantry(ref);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportSuccess)),
      );
    } catch (e) {
      final msg = e is ExportResult ? e.message : l10n.settingsExportError(e);
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _importPantry(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final json = await _pickJsonFile(context, l10n);
    if (json == null) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsImportCancelled)),
        );
      }
      return;
    }
    try {
      final result = await ImportService.importPantryFromJson(ref, json);
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success
                ? result.message
                : l10n.settingsImportError(result.message)),
          ),
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsImportError(e))),
        );
      }
    }
  }

  Future<void> _import(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Step 1: Select import mode
    final mode = await _showImportModeDialog(context, l10n);
    if (mode == null) return;
    if (!mounted || !context.mounted) return;

    // Step 2: Pick file
    final json = await _pickJsonFile(context, l10n);
    if (json == null) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsImportCancelled)),
        );
      }
      return;
    }

    // Step 3: Perform import
    try {
      final result = await ImportService.importFromJson(ref, json, mode);
      if (mounted && context.mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsImportError(result.message))),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsImportError(e))),
        );
      }
    }
  }

  Future<ImportMode?> _showImportModeDialog(
      BuildContext context, AppLocalizations l10n) async {
    return showDialog<ImportMode>(
      context: context,
      builder: (ctx) {
        final ctxL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxL10n.settingsImportModeTitle),
          content: Text(ctxL10n.settingsImportModeContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctxL10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ImportMode.merge),
              child: Text(ctxL10n.settingsImportModeMerge),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ImportMode.replace),
              child: Text(ctxL10n.settingsImportModeReplace),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _pickJsonFile(BuildContext context, AppLocalizations l10n) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: l10n.settingsImportPickDialogTitle,
      );
      if (result == null || result.files.isEmpty) return null;
      final picked = result.files.single;

      if (picked.bytes != null) {
        return utf8.decode(picked.bytes!);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _confirmClear(
      BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctxL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxL10n.settingsClearDialogTitle),
          content: Text(ctxL10n.settingsClearDialogContent),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctxL10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctxL10n.deleteAll),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ExportService.clearAll(ref);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsClearSuccess)),
        );
      }
    }
  }

  Future<void> _confirmResetDatabase(
      BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctxL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxL10n.settingsResetDbDialogTitle),
          content: Text(ctxL10n.settingsResetDbDialogContent),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctxL10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctxL10n.deleteAll),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      final isar = await ref.read(isarProvider.future);
      await isar.close(deleteFromDisk: true);
    } catch (_) {
      // Best-effort: even if close fails, we still try to signal the user.
    }
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsResetDbDone),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }
}

// ── Theme picker dialog ───────────────────────────────────────────────────────

class _ThemeDialog extends StatefulWidget {
  final ThemeMode current;
  const _ThemeDialog({required this.current});

  @override
  State<_ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<_ThemeDialog> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.settingsThemeDialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: RadioGroup<ThemeMode>(
        groupValue: _selected,
        onChanged: (v) => setState(() => _selected = v!),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              title: Text(l10n.settingsThemeSystem),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              title: Text(l10n.settingsThemeLight),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              title: Text(l10n.settingsThemeDark),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

// ── Language picker dialog ────────────────────────────────────────────────────

class _LanguageDialog extends StatefulWidget {
  final Locale? current;
  const _LanguageDialog({required this.current});

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current?.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.settingsLanguageDialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: RadioGroup<String?>(
        groupValue: _selected,
        onChanged: (v) => setState(() => _selected = v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              value: null,
              title: Text(l10n.settingsLanguageAuto),
              subtitle: const Text('🌐'),
            ),
            for (final locale
                in _supportedLocales.where((e) => e.code != null))
              RadioListTile<String?>(
                value: locale.code,
                title: Text(locale.label!),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected ?? '_auto_'),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

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
