import 'package:isar/isar.dart';

import '../../../../core/constants/food_categories.dart';
import '../models/ingredient.dart';

class IngredientRepository {
  final Isar _isar;
  IngredientRepository(this._isar);

  Future<List<Ingredient>> search({
    String query = '',
    FoodCategory? category,
    bool customOnly = false,
    int limit = 100,
    int offset = 0,
  }) async {
    final hasCategory = category != null;
    final hasQuery = query.isNotEmpty;

    if (!hasCategory && !hasQuery && !customOnly) {
      return _isar.ingredients
          .where()
          .sortByNameLower()
          .offset(offset)
          .limit(limit)
          .findAll();
    }

    final lower = query.toLowerCase();
    return _isar.ingredients
        .filter()
        .optional(customOnly, (q) => q.isSeededEqualTo(false))
        .optional(hasCategory, (q) => q.categoryEqualTo(category!))
        .optional(
          hasQuery,
          (q) => q.group(
            (g) => g
                .nameLowerContains(lower, caseSensitive: false)
                .or()
                .nameDEContains(lower, caseSensitive: false),
          ),
        )
        .sortByNameLower()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<Ingredient?> findById(int id) => _isar.ingredients.get(id);

  Future<void> save(Ingredient ingredient) async {
    await _isar.writeTxn(() => _isar.ingredients.put(ingredient));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.ingredients.delete(id));
  }

  Future<List<Ingredient>> allCustom() =>
      _isar.ingredients.filter().isSeededEqualTo(false).findAll();

  Future<List<Ingredient>> all() => _isar.ingredients.where().findAll();

  Future<void> deleteAllCustom() async {
    final customs = await allCustom();
    final ids = customs.map((i) => i.id).toList();
    await _isar.writeTxn(() => _isar.ingredients.deleteAll(ids));
  }

  Future<int> count() => _isar.ingredients.count();
}
