import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class AppResultDialog {
  AppResultDialog._();

  /// Thông báo thành công
  static Future<void> showSuccess(
    BuildContext context, {
    String title = 'Thành công 🎉',
    required String message,
    String buttonText = 'Tiếp tục',
    VoidCallback? onAction,
    bool barrierDismissible = false,
  }) async {
    await _show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.secondary,
      onAction: onAction,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Thông báo thất bại
  static Future<void> showError(
    BuildContext context, {
    String title = 'Đã xảy ra lỗi',
    required String message,
    String buttonText = 'Đóng',
    VoidCallback? onAction,
    bool barrierDismissible = false,
  }) async {
    await _show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
      onAction: onAction,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onAction,
    required bool barrierDismissible,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onAction?.call();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
