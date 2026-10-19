import 'package:flutter/material.dart';

/// Bảng màu đồng bộ với bản React Native (src/theme/colors.ts).
///
/// - [AppColors]: tương ứng `COLORS` bên RN, kèm các tên cũ của Flutter
///   (đã đổi giá trị sang màu RN để code hiện tại không phải sửa).
/// - [MomTheme]: tương ứng `MOM_THEME` bên RN.
class AppColors {
  AppColors._();

  // =========================
  // Primary - Rose
  // =========================
  static const Color primary = Color(0xFFC97A95);
  static const Color primaryDark = Color(0xFFB85B7A);
  static const Color primaryLight = Color(0xFFFFF0F5);
  static const Color primarySoft = Color(0xFFFBE8EF);

  // =========================
  // Secondary - Sage
  // =========================
  static const Color secondary = Color(0xFF8AA898);
  static const Color secondaryDark = Color(0xFF5F7A6B);
  static const Color secondaryLight = Color(0xFFE8F2EC);

  // =========================
  // Accents
  // =========================
  static const Color emerald = Color(0xFF5F7A6B);
  static const Color emeraldLight = Color(0xFFE8F2EC);
  static const Color amber = Color(0xFFE8A87C);
  static const Color amberLight = Color(0xFFFFF4EB);
  static const Color rose = Color(0xFFD95368);
  static const Color roseLight = Color(0xFFFDECEF);
  static const Color blue = Color(0xFF6C92BF);
  static const Color blueLight = Color(0xFFEEF4FA);
  static const Color purple = Color(0xFFA799B7);
  static const Color purpleLight = Color(0xFFF3EEF8);

  // =========================
  // Neutrals
  // =========================
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAF6F0);
  static const Color backgroundSoft = Color(0xFFF5EFE6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C2118);
  static const Color textMuted = Color(0xFF7A6E65);
  static const Color textLight = Color(0xFFA69B92);
  static const Color border = Color(0xFFEFE7DC);
  static const Color borderLight = Color(0xFFF6F0E8);

  // =========================
  // Gradients
  // =========================
  static const List<Color> gradientPink = [Color(0xFFE8B4C4), Color(0xFFC97A95)];
  static const List<Color> gradientSage = [Color(0xFF8AA898), Color(0xFF5F7A6B)];
  static const List<Color> gradientPurple = [Color(0xFFA799B7), Color(0xFF7C5CFC)];
  static const List<Color> gradientAmber = [Color(0xFFE8A87C), Color(0xFFD9824B)];

  // =========================
  // Tên cũ của Flutter (giữ để không vỡ code), map sang màu RN
  // =========================
  static const Color primaryContainer = primary;
  static const Color mintLight = secondaryLight;
  static const Color calmTeal = secondaryDark;

  static const Color aiPurple = purple;
  static const Color aiPurpleSoft = purpleLight;

  static const Color emergencyRed = rose;
  static const Color redLight = roseLight;

  static const Color warningYellow = amber;
  static const Color yellowLight = amberLight;

  static const Color surface = card;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;

  static const Color onPrimary = white;

  static const Color error = rose;
  static const Color errorContainer = roseLight;

  static const Color onSurface = textDark;
  static const Color onSurfaceVariant = MomTheme.charcoalMid;
  static const Color outline = textMuted;
  static const Color outlineVariant = MomTheme.beige;
}

/// Tương ứng `MOM_THEME` bên React Native.
class MomTheme {
  MomTheme._();

  static const Color cream = Color(0xFFFAF6F0);
  static const Color cream2 = Color(0xFFF5EFE6);
  static const Color creamSoft = Color(0xFFFCF9F5);
  static const Color rose = Color(0xFFE8B4C4);
  static const Color roseDark = Color(0xFFC97A95);
  static const Color roseMid = Color(0xFFD4869C);
  static const Color roseDeep = Color(0xFFB85B7A);
  static const Color pink = Color(0xFFF2D0DC);
  static const Color pinkLight = Color(0xFFFFF0F5);
  static const Color sage = Color(0xFF8AA898);
  static const Color sageDark = Color(0xFF5F7A6B);
  static const Color sageLight = Color(0xFFE8F2EC);
  static const Color sageMuted = Color(0xFFA3BDB0);
  static const Color amber = Color(0xFFE8A87C);
  static const Color amberLight = Color(0xFFFFF4EB);
  static const Color amberDark = Color(0xFFC97842);
  static const Color lavender = Color(0xFFA799B7);
  static const Color lavenderLight = Color(0xFFF3EEF8);
  static const Color beige = Color(0xFFE8DDD0);
  static const Color beigeLight = Color(0xFFF2EBE1);
  static const Color charcoal = Color(0xFF2C2118);
  static const Color charcoalMid = Color(0xFF4A3F35);
  static const Color muted = Color(0xFF7A6E65);
  static const Color mutedLight = Color(0xFFA69B92);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEFE7DC);
  static const Color borderSoft = Color(0xFFF3EDE4);
}
