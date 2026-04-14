import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/constants/food_categories.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../pantry/data/models/ingredient.dart';
import '../../data/models/meal_ingredient.dart';
import '../../data/models/meal_template.dart';
import '../../providers/meal_template_providers.dart';
import '../widgets/meal_ingredient_chip.dart';

class EditTemplateSheet extends ConsumerStatefulWidget {
  /// When non-null, the sheet operates in edit mode for this template.
  final MealTemplate? initialTemplate;

  const EditTemplateSheet({super.key, this.initialTemplate});

  @override
  ConsumerState<EditTemplateSheet> createState() => _EditTemplateSheetState();
}

class _EditTemplateSheetState extends ConsumerState<EditTemplateSheet> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  String? _mealLabel;
  final List<MealIngredient> _selectedIngredients = [];

  // Browse mode
  FoodCategory? _activeCategory;
  List<Ingredient> _browseResults = [];
  bool _loadingBrowse = false;

  // Search mode
  List<Ingredient> _searchResults = [];
  bool _searching = false;

  bool _saving = false;

  bool get _isEditing => widget.initialTemplate != null;

  static const _mealLabels = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  bool get _isSearching => _searchController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final template = widget.initialTemplate;
    if (template != null) {
      _nameController.text = template.name;
      _mealLabel = template.mealLabel;
      _selectedIngredients.addAll(template.ingredients);
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _selectCategory(FoodCategory.vegetable));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _isEditing
                        ? l10n.mealTemplateEditTitle
                        : l10n.mealTemplateCreateTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Template name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.mealTemplateNameHint,
                  prefixIcon: const Icon(Icons.bookmark_outline),
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 8),

            // Meal type (optional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: _mealLabels
                    .map((lbl) => ButtonSegment(
                          value: lbl,
                          label: Text(localizedMealLabel(lbl, l10n)),
                        ))
                    .toList(),
                selected: _mealLabel != null ? {_mealLabel!} : {},
                emptySelectionAllowed: true,
                onSelectionChanged: (s) =>
                    setState(() => _mealLabel = s.isEmpty ? null : s.first),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 1),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.logMealSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        )
                      : null,
                  isDense: true,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Category chips (hidden while searching)
            if (!_isSearching)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: FoodCategory.values.map((cat) {
                    final selected = _activeCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        avatar: Icon(cat.icon,
                            size: 16, color: selected ? null : cat.color),
                        label: Text(cat.localizedName(l10n)),
                        selected: selected,
                        onSelected: (_) => _selectCategory(cat),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 4),

            // Ingredient list
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(l10n)
                  : _buildBrowseList(l10n),
            ),

            // Selected ingredients
            if (_selectedIngredients.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.logMealAdded,
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _selectedIngredients
                          .map((i) => MealIngredientChip(
                                item: i,
                                onDelete: () => setState(
                                    () => _selectedIngredients.remove(i)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseList(AppLocalizations l10n) {
    if (_loadingBrowse) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: _browseResults.length,
      itemBuilder: (_, i) => _IngredientTile(
        ingredient: _browseResults[i],
        l10n: l10n,
        isAdded: _selectedIngredients
            .any((s) => s.ingredientId == _browseResults[i].id),
        onTap: () => _toggleIngredient(_browseResults[i]),
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return Center(
          child: Text(l10n.pantryNoResults(_searchController.text)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: _searchResults.length,
      itemBuilder: (_, i) => _IngredientTile(
        ingredient: _searchResults[i],
        l10n: l10n,
        isAdded: _selectedIngredients
            .any((s) => s.ingredientId == _searchResults[i].id),
        onTap: () => _toggleIngredient(_searchResults[i]),
      ),
    );
  }

  Future<void> _selectCategory(FoodCategory cat) async {
    setState(() {
      _activeCategory = cat;
      _loadingBrowse = true;
    });
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final results = await db.searchIngredients(category: cat, limit: 60);
      if (mounted) setState(() => _browseResults = results);
    } finally {
      if (mounted) setState(() => _loadingBrowse = false);
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {});
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final results = await db.searchIngredients(query: query, limit: 20);
      if (mounted) setState(() => _searchResults = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _toggleIngredient(Ingredient ingredient) {
    setState(() {
      final alreadyAdded =
          _selectedIngredients.any((s) => s.ingredientId == ingredient.id);
      if (alreadyAdded) {
        _selectedIngredients
            .removeWhere((s) => s.ingredientId == ingredient.id);
      } else {
        _selectedIngredients.add(MealIngredient()
          ..ingredientId = ingredient.id
          ..ingredientName = ingredient.name);
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mealTemplateNameRequired)),
      );
      return;
    }
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logMealValidation)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final template = MealTemplate()
        ..name = name
        ..mealLabel = _mealLabel
        ..ingredients = _selectedIngredients;

      if (_isEditing) {
        template.id = widget.initialTemplate!.id;
        template.createdAt = widget.initialTemplate!.createdAt;
      }

      await ref.read(mealTemplateProvider.notifier).saveTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mealTemplateSaved)),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Ingredient tile (same as LogMealSheet) ───────────────────────────────────

class _IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final AppLocalizations l10n;
  final bool isAdded;
  final VoidCallback onTap;

  const _IngredientTile({
    required this.ingredient,
    required this.l10n,
    required this.isAdded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final fodmap = ingredient.fodmapLevel;
    final fodmapColor = fodmap == 'low'
        ? Colors.green
        : fodmap == 'moderate'
            ? Colors.orange
            : Colors.red;

    return ListTile(
      leading:
          Icon(ingredient.category.icon, color: ingredient.category.color),
      title: Text(ingredient.localizedName(locale)),
      subtitle: Text(ingredient.category.localizedName(l10n)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: fodmapColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              fodmap.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: fodmapColor),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline,
            color: isAdded
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ],
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
