import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Bidirectional EN↔DE lookup for food/ingredient names.
///
/// Loaded once from `assets/seed/food_dictionary.json` and cached in memory.
/// Lookups are case-insensitive; results preserve the original casing from the
/// dictionary.
class FoodDictionary {
  FoodDictionary._({
    required Map<String, String> enToDe,
    required Map<String, String> deToEn,
  }) : _enToDe = enToDe,
       _deToEn = deToEn;

  final Map<String, String> _enToDe;
  final Map<String, String> _deToEn;

  static FoodDictionary? _instance;

  /// Returns the singleton, loading the asset on first call.
  static Future<FoodDictionary> load() async {
    if (_instance != null) return _instance!;

    final raw = await rootBundle.loadString('assets/seed/food_dictionary.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final entries = (json['entries'] as List).cast<Map<String, dynamic>>();

    final enToDe = <String, String>{};
    final deToEn = <String, String>{};

    for (final e in entries) {
      final en = e['en'] as String;
      final de = e['de'] as String;
      enToDe[en.toLowerCase()] = de;
      deToEn[de.toLowerCase()] = en;
    }

    _instance = FoodDictionary._(enToDe: enToDe, deToEn: deToEn);
    return _instance!;
  }

  /// Look up the German name for an English ingredient (case-insensitive).
  String? enToDe(String english) => _enToDe[english.toLowerCase()];

  /// Look up the English name for a German ingredient (case-insensitive).
  String? deToEn(String german) => _deToEn[german.toLowerCase()];

  /// Translate [name] entered in [sourceLanguage] to the other language.
  ///
  /// Returns `null` when the term is not in the dictionary.
  String? translate(String name, {required String sourceLanguage}) {
    if (sourceLanguage == 'de') return deToEn(name);
    return enToDe(name);
  }
}
