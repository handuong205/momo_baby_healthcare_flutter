import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart' as base;


class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,

    // ============================================================
    // FONT
    // ============================================================

    fontFamily: 'PlusJakartaSans',

    // ============================================================
    // COLORS
    // ============================================================

    colorScheme: const ColorScheme.light(
      primary: base.AppColors.primary,
      onPrimary: base.AppColors.onPrimary,

      secondary: base.AppColors.secondary,

      surface: base.AppColors.surface,

      error: base.AppColors.aiPurple,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: base.AppColors.background,

    // ============================================================
    // TEXT
    // ============================================================

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 52 / 44,
        color: base.AppColors.textPrimary,
      ),

      headlineLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: base.AppColors.textPrimary,
      ),

      headlineMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: base.AppColors.textPrimary,
      ),

      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: base.AppColors.textPrimary,
      ),

      bodyLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: base.AppColors.textPrimary,
      ),

      bodyMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: base.AppColors.textPrimary,
      ),

      bodySmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: base.AppColors.textPrimary,
      ),

      labelLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: base.AppColors.textPrimary,
      ),

      labelMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: base.AppColors.textPrimary,
      ),

      labelSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.24,
        color: base.AppColors.textPrimary,
      ),
    ),

    // ============================================================
    // APP BAR
    // ============================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: base.AppColors.background,
      foregroundColor: base.AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    // ============================================================
    // BUTTON
    // ============================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: base.AppColors.primary,
        foregroundColor: Colors.white,

        minimumSize: const Size(double.infinity, 52),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),

        textStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        elevation: 0,
      ),
    ),

    // ============================================================
    // TEXT FIELD
    // ============================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: base.AppColors.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      hintStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        color: base.AppColors.textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: base.AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: base.AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: base.AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: base.AppColors.error,
        ),
      ),
    ),

    // ============================================================
    // CARD
    // ============================================================

    cardTheme: CardThemeData(
      color: base.AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );

  // Theme used by the Mom Ơi entrypoint (lib/main_mom_oi.dart)
  static ThemeData get momOi => ThemeData(
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

// Palette used by lib/features/** (Mom Ơi). The default palette is in core/colors/app_colors.dart.
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

class AppRadii {
  static const control = 14.0;
  static const card = 20.0;
  static const hero = 28.0;
  static const pill = 999.0;
}
