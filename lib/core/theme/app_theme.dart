import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';


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
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,

      secondary: AppColors.secondary,

      surface: AppColors.surface,

      error: AppColors.aiPurple,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: AppColors.background,

    // ============================================================
    // TEXT
    // ============================================================

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 52 / 44,
        color: AppColors.textPrimary,
      ),

      headlineLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: AppColors.textPrimary,
      ),

      headlineMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.textPrimary,
      ),

      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.textPrimary,
      ),

      bodyLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.textPrimary,
      ),

      bodyMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      ),

      bodySmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.textPrimary,
      ),

      labelLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.textPrimary,
      ),

      labelMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: AppColors.textPrimary,
      ),

      labelSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.24,
        color: AppColors.textPrimary,
      ),
    ),

    // ============================================================
    // APP BAR
    // ============================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    // ============================================================
    // BUTTON
    // ============================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
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
      fillColor: AppColors.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      hintStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        color: AppColors.textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
    ),

    // ============================================================
    // CARD
    // ============================================================

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}