import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';


class SocialLoginSection extends StatelessWidget {
  final VoidCallback onRegister;

  const SocialLoginSection({
    super.key, 
    required this.onRegister,
});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Divider
        Stack(
          alignment: Alignment.center,
          children: [
            const Divider(
              color: AppColors.border,
              height: 1,
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              color: AppColors.primaryLight,
              child: Text(
                'Hoặc tiếp tục với',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Social buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              child: const Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4285F4),
                ),
              ),
              onPressed: () {
                // TODO: Google Login
              },
            ),

            const SizedBox(width: 16),

            _SocialButton(
              child: const Icon(
                Icons.apple,
                size: 24,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                // TODO: Apple Login
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Register
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mẹ chưa có tài khoản?',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            TextButton(
              onPressed: onRegister,       
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Đăng ký ngay 💖',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}