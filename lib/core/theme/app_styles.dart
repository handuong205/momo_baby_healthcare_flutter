import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

/// Bo góc, tương ứng `RADII` bên React Native (src/theme/colors.ts).
class AppRadii {
  AppRadii._();

  static const double control = 14;
  static const double card = 20;
  static const double cardLg = 26;
  static const double hero = 28;
  static const double pill = 999;
}

/// Đổ bóng, tương ứng `SHADOWS` bên React Native.
///
/// Dùng: `BoxDecoration(boxShadow: AppShadows.card)`.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A2C2118), // charcoal, opacity 0.04
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F2C2118), // charcoal, opacity 0.06
      offset: Offset(0, 4),
      blurRadius: 10,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D2C2118), // charcoal, opacity 0.05
      offset: Offset(0, 6),
      blurRadius: 14,
    ),
  ];

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.18),
      offset: const Offset(0, 6),
      blurRadius: 12,
    ),
  ];
}
