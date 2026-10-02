import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class BiometricButton extends StatefulWidget {
  const BiometricButton({super.key});

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton> {
  bool _loading = false;
  bool _success = false;

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _success = false;
    });

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _success = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    // TODO:
    // Navigate vào HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: _loading ? null : _authenticate,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.mintLight,
          foregroundColor: AppColors.secondary,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            else if (_success)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.secondary,
              )
            else
              const Icon(
                Icons.fingerprint,
                size: 18,
                color: AppColors.secondary,
              ),

            const SizedBox(width: 8),

            Text(
              _loading
                  ? 'Đang xác thực bảo mật...'
                  : _success
                      ? 'Xác thực thành công! Đang vào app...'
                      : 'Đăng nhập nhanh bằng FaceID / Vân tay 🫧',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}