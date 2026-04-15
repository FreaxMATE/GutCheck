import 'package:isar/isar.dart';

import '../../../../core/constants/food_categories.dart';

part 'ingredient_native.g.dart';

@collection
class Ingredient {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  late String nameLower;

  @enumerated
  late FoodCategory category;

  /// 'low' | 'moderate' | 'high'
  late String fodmapLevel;

  /// true = came from seed JSON; false = user-created
  @Index()
  late bool isSeeded;

  /// Optional secondary category stored as string (Isar 3.x doesn't support nullable enums)
  String? secondaryCategoryName;

  /// German display name (null = not yet translated)
  String? nameDE;

  String? photoPath;
  String? notes;

  DateTime createdAt = DateTime.now();

  /// Returns the display name for [languageCode] ('de' uses nameDE when set).
  String localizedName(String languageCode) {
    if (languageCode == 'de' && nameDE != null && nameDE!.isNotEmpty) {
      return nameDE!;
    }
    return name;
  }

  /// Resolved secondary category (null if none)
  @ignore
  FoodCategory? get secondaryCategory {
    if (secondaryCategoryName == null) return null;
    try {
      return FoodCategory.values.byName(secondaryCategoryName!);
    } catch (_) {
      return null;
    }
  }
}
