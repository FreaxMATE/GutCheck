import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/food_categories.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/providers/sound_provider.dart';
import '../../../pantry/data/models/ingredient.dart';
import '../../data/models/meal_entry.dart';
import '../../data/models/meal_ingredient.dart';
import '../../providers/meal_providers.dart';
import '../widgets/meal_ingredient_chip.dart';
import '../widgets/meal_plate.dart';

class LogMealSheet extends ConsumerStatefulWidget {
  /// When non-null, the sheet operates in edit mode for this entry.
  final MealEntry? initialEntry;

  /// When true and [initialEntry] is set, pre-fills from the entry but
  /// creates a new meal on save (used when applying a template).
  final bool isNewFromTemplate;

  const LogMealSheet({
    super.key,
    this.initialEntry,
    this.isNewFromTemplate = false,
  });

  @override
  ConsumerState<LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends ConsumerState<LogMealSheet> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();

  String _mealLabel = 'Lunch';
  DateTime _consumedAt = DateTime.now();
  final List<MealIngredient> _selectedIngredients = [];
  // Cached category per selected ingredient, for the MealPlate visualization.
  final Map<int, FoodCategory> _categoryByIngredientId = {};

  // Browse mode
  FoodCategory? _activeCategory;
  List<Ingredient> _browseResults = [];
  bool _loadingBrowse = false;

  // Search mode
  List<Ingredient> _searchResults = [];
  bool _searching = false;

  bool _saving = false;

  bool get _isEditing =>
      widget.initialEntry != null && !widget.isNewFromTemplate;

  static const _mealLabels = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  bool get _isSearching => _searchController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    if (entry != null && !widget.isNewFromTemplate) {
      // Edit mode: restore all fields from the existing entry.
      _mealLabel = entry.mealLabel ?? 'Lunch';
      _consumedAt = entry.consumedAt;
      _selectedIngredients.addAll(entry.ingredients);
      if (entry.notes != null) _notesController.text = entry.notes!;
    } else if (entry != null && widget.isNewFromTemplate) {
      // Template pre-fill: use template ingredients + label, but fresh time.
      _mealLabel = entry.mealLabel ?? 'Lunch';
      if (entry.mealLabel == null) _setSmartLabel();
      _selectedIngredients.addAll(entry.ingredients);
    } else {
      _setSmartLabel();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectCategory(FoodCategory.vegetable);
      _populateCategoriesForSelected();
    });
  }

  Future<void> _populateCategoriesForSelected() async {
    if (_selectedIngredients.isEmpty) return;
    final db = await ref.read(appDatabaseProvider.future);
    for (final mi in _selectedIngredients) {
      if (_categoryByIngredientId.containsKey(mi.ingredientId)) continue;
      final ing = await db.findIngredientById(mi.ingredientId);
      if (ing != null && mounted) {
        setState(() {
          _categoryByIngredientId[mi.ingredientId] = ing.category;
        });
      }
    }
  }

  void _setSmartLabel() {
    final hour = DateTime.now().hour;
    if (hour < 10) {
      _mealLabel = 'Breakfast';
    } else if (hour < 14) {
      _mealLabel = 'Lunch';
    } else if (hour < 18) {
      _mealLabel = 'Dinner';
    } else {
      _mealLabel = 'Snack';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
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
                    _isEditing ? l10n.mealEditTitle : l10n.logMealTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Meal type
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: _mealLabels
                    .map(
                      (lbl) => ButtonSegment(
                        value: lbl,
                        label: Text(localizedMealLabel(lbl, l10n)),
                      ),
                    )
                    .toList(),
                selected: {_mealLabel},
                onSelectionChanged: (s) => setState(() => _mealLabel = s.first),
              ),
            ),
            const SizedBox(height: 4),

            // Date & time row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.event_rounded),
                      title: Text(
                        DateFormat.yMMMd(
                          Localizations.localeOf(context).toString(),
                        ).format(_consumedAt),
                      ),
                      onTap: _pickDate,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time_rounded),
                      title: Text(
                        '${_consumedAt.hour.toString().padLeft(2, '0')}:'
                        '${_consumedAt.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: _pickTime,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
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
                        avatar: Icon(
                          cat.icon,
                          size: 16,
                          color: selected ? null : cat.color,
                        ),
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

            // Selected ingredients + live MealPlate
            if (_selectedIngredients.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MealPlate(categoryCounts: _plateCounts, size: 80),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.logMealAdded,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _selectedIngredients
                                .map(
                                  (i) => MealIngredientChip(
                                    item: i,
                                    onDelete: () {
                                      setState(() {
                                        _selectedIngredients.remove(i);
                                        _categoryByIngredientId.remove(
                                          i.ingredientId,
                                        );
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Notes
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: l10n.logMealNotesHint,
                  prefixIcon: const Icon(Icons.note_outlined),
                  isDense: true,
                ),
                maxLines: 2,
              ),
            ),
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
        isAdded: _selectedIngredients.any(
          (s) => s.ingredientId == _browseResults[i].id,
        ),
        onTap: () => _toggleIngredient(_browseResults[i]),
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return Center(child: Text(l10n.pantryNoResults(_searchController.text)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: _searchResults.length,
      itemBuilder: (_, i) => _IngredientTile(
        ingredient: _searchResults[i],
        l10n: l10n,
        isAdded: _selectedIngredients.any(
          (s) => s.ingredientId == _searchResults[i].id,
        ),
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
      final alreadyAdded = _selectedIngredients.any(
        (s) => s.ingredientId == ingredient.id,
      );
      if (alreadyAdded) {
        _selectedIngredients.removeWhere(
          (s) => s.ingredientId == ingredient.id,
        );
        _categoryByIngredientId.remove(ingredient.id);
      } else {
        _selectedIngredients.add(
          MealIngredient()
            ..ingredientId = ingredient.id
            ..ingredientName = ingredient.name,
        );
        _categoryByIngredientId[ingredient.id] = ingredient.category;
        // Playful gurgle on add (opt-in, off by default).
        playGurgle(ref);
      }
    });
  }

  Map<FoodCategory, int> get _plateCounts {
    final counts = <FoodCategory, int>{};
    for (final mi in _selectedIngredients) {
      // Use FoodCategory.other as fallback when the async category lookup
      // hasn't completed yet — so the plate total always matches the chip count.
      final cat =
          _categoryByIngredientId[mi.ingredientId] ?? FoodCategory.other;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _consumedAt,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _consumedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _consumedAt.hour,
          _consumedAt.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_consumedAt),
    );
    if (picked != null && mounted) {
      setState(() {
        _consumedAt = DateTime(
          _consumedAt.year,
          _consumedAt.month,
          _consumedAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.logMealValidation)));
      return;
    }

    setState(() => _saving = true);
    try {
      final entry = MealEntry()
        ..consumedAt = _consumedAt
        ..mealLabel = _mealLabel
        ..ingredients = _selectedIngredients
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim();

      if (_isEditing) {
        entry.id = widget.initialEntry!.id;
        entry.createdAt = widget.initialEntry!.createdAt;
        await ref.read(mealLogProvider.notifier).updateMeal(entry);
      } else {
        await ref.read(mealLogProvider.notifier).addMeal(entry);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Ingredient tile ───────────────────────────────────────────────────────────

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
      leading: Icon(ingredient.category.icon, color: ingredient.category.color),
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
                color: fodmapColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedToggleIcon(
            active: isAdded,
            activeIcon: Icons.check_circle_rounded,
            inactiveIcon: Icons.add_circle_outline,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Colors.grey,
          ),
        ],
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
