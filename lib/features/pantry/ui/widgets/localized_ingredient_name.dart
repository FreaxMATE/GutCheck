import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pantry_providers.dart';

/// Looks up an ingredient by [ingredientId] and displays its locale-appropriate
/// name. Falls back to [fallbackName] (usually the denormalized English name
/// stored at log time) if the ingredient has been deleted.
class LocalizedIngredientText extends ConsumerWidget {
  final int ingredientId;
  final String fallbackName;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const LocalizedIngredientText({
    super.key,
    required this.ingredientId,
    required this.fallbackName,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final async = ref.watch(singleIngredientProvider(ingredientId));
    final name = async.maybeWhen(
      data: (ing) => ing?.localizedName(locale) ?? fallbackName,
      orElse: () => fallbackName,
    );
    return Text(
      name,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
