import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/food_categories.dart';

/// Tappable wrapper that emits an ink ripple tinted with a food category's
/// color when the child is tapped. Falls back to a generic splash if no
/// category is provided.
class CategoryRipple extends StatelessWidget {
  final FoodCategory? category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Widget child;

  const CategoryRipple({
    super.key,
    required this.child,
    this.category,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? AppColors.wellnessGreen;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: color.withValues(alpha: 0.25),
        highlightColor: color.withValues(alpha: 0.08),
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
