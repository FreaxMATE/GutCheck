import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/food_categories.dart';
import '../../../core/database/app_database_provider.dart';
import '../data/models/ingredient.dart';

final pantrySearchQueryProvider = StateProvider<String>((ref) => '');

final pantryCategoryFilterProvider =
    StateProvider<FoodCategory?>((ref) => null);

final pantryCustomOnlyProvider = StateProvider<bool>((ref) => false);

final pagedIngredientsProvider =
    FutureProvider.autoDispose<List<Ingredient>>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final query = ref.watch(pantrySearchQueryProvider);
  final category = ref.watch(pantryCategoryFilterProvider);
  final customOnly = ref.watch(pantryCustomOnlyProvider);
  return db.searchIngredients(
    query: query,
    category: category,
    customOnly: customOnly,
    limit: 200,
  );
});

final ingredientCountProvider = FutureProvider<int>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.ingredientCount();
});

final singleIngredientProvider =
    FutureProvider.autoDispose.family<Ingredient?, int>((ref, id) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.findIngredientById(id);
});
