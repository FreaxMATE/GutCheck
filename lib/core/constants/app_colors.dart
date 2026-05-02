import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seedGreen = Color(0xFF2E7D32);
  static const Color wellnessGreen = Color(0xFF4CAF50);
  static const Color wellnessAmber = Color(0xFFFFC107);
  static const Color wellnessRed = Color(0xFFE53935);

  static const Color vegetable = Color(0xFF2E7D32);
  static const Color fruit = Color(0xFFAD1457);
  static const Color grain = Color(0xFFF9A825);
  static const Color protein = Color(0xFF37474F);
  static const Color dairy = Color(0xFF1565C0);
  static const Color legume = Color(0xFF33691E);
  static const Color fat = Color(0xFFFF8F00);
  static const Color herb = Color(0xFF00695C);
  static const Color spice = Color(0xFFBF360C);
  static const Color beverage = Color(0xFF0277BD);
  static const Color other = Color(0xFF546E7A);

  static Color wellnessScore(double score) {
    if (score >= 70) return wellnessGreen;
    if (score >= 40) return wellnessAmber;
    return wellnessRed;
  }

  static Color wellnessScoreInterpolated(double score) {
    final s = score.clamp(0.0, 100.0);
    if (s <= 30) return wellnessRed;
    if (s >= 60) {
      return Color.lerp(wellnessAmber, wellnessGreen, (s - 60) / 40.0)!;
    }
    return Color.lerp(wellnessRed, wellnessAmber, (s - 30) / 30.0)!;
  }
}
