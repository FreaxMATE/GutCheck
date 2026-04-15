import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/constants/food_categories.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/l10n/food_dictionary.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../data/models/ingredient.dart';
import '../../providers/pantry_providers.dart';

class AddCustomFoodScreen extends ConsumerStatefulWidget {
  const AddCustomFoodScreen({super.key});

  @override
  ConsumerState<AddCustomFoodScreen> createState() =>
      _AddCustomFoodScreenState();
}

class _AddCustomFoodScreenState extends ConsumerState<AddCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _translationController = TextEditingController();
  final _notesController = TextEditingController();

  FoodCategory _category = FoodCategory.other;
  String _fodmapLevel = 'low';
  bool _saving = false;
  bool _autoTranslated = false;
  FoodDictionary? _dictionary;

  @override
  void initState() {
    super.initState();
    _loadDictionary();
    _nameController.addListener(_onNameChanged);
  }

  Future<void> _loadDictionary() async {
    _dictionary = await FoodDictionary.load();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _translationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final dict = _dictionary;
    if (dict == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (_autoTranslated) {
        _translationController.clear();
        setState(() => _autoTranslated = false);
      }
      return;
    }

    final lang = Localizations.localeOf(context).languageCode;
    final result = dict.translate(name, sourceLanguage: lang);

    if (result != null) {
      _translationController.text = result;
      setState(() => _autoTranslated = true);
    } else if (_autoTranslated) {
      // Previous auto-fill no longer matches — clear it
      _translationController.clear();
      setState(() => _autoTranslated = false);
    }
  }

  /// Whether the user is currently typing in German.
  bool get _isGerman =>
      Localizations.localeOf(context).languageCode == 'de';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addFoodTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Primary name (in the user's current language) ──
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.addFoodNameLabel,
                hintText: l10n.addFoodNameHint,
                prefixIcon: const Icon(Icons.fastfood_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.addFoodNameRequired : null,
            ),
            const SizedBox(height: 16),

            // ── Translation field (other language) ──
            TextFormField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: _isGerman
                    ? l10n.addFoodNameENLabel
                    : l10n.addFoodNameDELabel,
                hintText: _isGerman
                    ? l10n.addFoodNameENHint
                    : l10n.addFoodNameDEHint,
                prefixIcon: const Icon(Icons.translate_rounded),
                helperText:
                    _autoTranslated ? l10n.addFoodAutoTranslated : null,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                // User edited manually — stop treating it as auto-filled
                if (_autoTranslated) {
                  setState(() => _autoTranslated = false);
                }
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<FoodCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.addFoodCategoryLabel,
                prefixIcon: const Icon(Icons.category_rounded),
              ),
              items: FoodCategory.values
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 20),
                            const SizedBox(width: 8),
                            Text(cat.localizedName(l10n)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _fodmapLevel,
              decoration: InputDecoration(
                labelText: l10n.addFoodFodmapLabel,
                prefixIcon: const Icon(Icons.warning_amber_rounded),
              ),
              items: [
                DropdownMenuItem(value: 'low', child: Text(l10n.addFoodFodmapLow)),
                DropdownMenuItem(value: 'moderate', child: Text(l10n.addFoodFodmapModerate)),
                DropdownMenuItem(value: 'high', child: Text(l10n.addFoodFodmapHigh)),
              ],
              onChanged: (v) => setState(() => _fodmapLevel = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.wellnessNotesLabel,
                hintText: l10n.addFoodNotesHint,
                prefixIcon: const Icon(Icons.note_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(l10n.addFoodSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final primaryName = _nameController.text.trim();
      final translation = _translationController.text.trim();

      // Determine which field is EN and which is DE based on locale.
      final String englishName;
      final String? germanName;

      if (_isGerman) {
        // User typed in German → primary is DE, translation is EN
        germanName = primaryName;
        englishName = translation.isNotEmpty ? translation : primaryName;
      } else {
        // User typed in English → primary is EN, translation is DE
        englishName = primaryName;
        germanName = translation.isNotEmpty ? translation : null;
      }

      final ingredient = Ingredient()
        ..name = englishName
        ..nameLower = englishName.toLowerCase()
        ..nameDE = germanName
        ..category = _category
        ..fodmapLevel = _fodmapLevel
        ..isSeeded = false
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim();

      await db.saveIngredient(ingredient);
      ref.invalidate(pagedIngredientsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.addFoodAdded(ingredient.name))),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
