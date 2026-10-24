import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/register_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/widgets/login/biometric_button.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/widgets/login/login_form.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/widgets/login/login_header.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/widgets/login/social_login_section.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blob góc trên bên phải
            Positioned(
              top: -70,
              right: -70,
              child: _DecorativeBlob(
                size: 220,
                color: AppColors.primaryLight,
                blur: 35,
              ),
            ),

            // Decorative blob bên trái
            Positioned(
              top: 180,
              left: -80,
              child: _DecorativeBlob(
                size: 210,
                color: AppColors.aiPurpleSoft,
                blur: 30,
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 8),
                  const LoginForm(),
                  const SizedBox(height: 12),
                  const BiometricButton(),
                  const SizedBox(height: 20),
                  SocialLoginSection(
  onRegister: () {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const RegisterScreen();
        },
        transitionDuration: const Duration(
          milliseconds: 350,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 350,
        ),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
      ),
    );
  },
),
                  const SizedBox(height: 16),
                  _PrivacyBadge(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _DecorativeBlob({
    required this.size,
    required this.color,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ColorFilter.mode(
          color.withValues(alpha: 0.7),
          BlendMode.srcOver,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user,
            size: 15,
            color: AppColors.calmTeal,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Dữ liệu sức khỏe Mẹ & Bé được mã hóa chuẩn y tế',
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}