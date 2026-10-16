import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFC97A95);
  static const primaryDark = Color(0xFFB85B7A);
  static const primaryLight = Color(0xFFFFF0F5);
  static const primarySoft = Color(0xFFFBE8EF);
  static const sage = Color(0xFF8AA898);
  static const sageDark = Color(0xFF5F7A6B);
  static const sageLight = Color(0xFFE8F2EC);
  static const cream = Color(0xFFFAF6F0);
  static const creamSoft = Color(0xFFFCF9F5);
  static const pink = Color(0xFFF2D0DC);
  static const pinkLight = Color(0xFFFFF0F5);
  static const amber = Color(0xFFE8A87C);
  static const amberDark = Color(0xFFC97842);
  static const charcoal = Color(0xFF2C2118);
  static const charcoalMid = Color(0xFF4A3F35);
  static const muted = Color(0xFF7A6E65);
  static const mutedLight = Color(0xFFA69B92);
  static const white = Colors.white;
  static const border = Color(0xFFEFE7DC);
  static const borderSoft = Color(0xFFF3EDE4);
  static const roseLight = Color(0xFFFDECEF);
  static const rose = Color(0xFFD95368);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.charcoal,
        ),
    fontFamily: 'Roboto',
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      isDense: true,
    ),
  );
}

class AppRadii {
  static const control = 14.0;
  static const card = 20.0;
  static const hero = 28.0;
  static const pill = 999.0;
}
