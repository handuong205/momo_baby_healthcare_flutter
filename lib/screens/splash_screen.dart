import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/repositories/auth/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/login_screen.dart';
import 'package:momo_baby_healthcare_flutter/services/token_service.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final refreshToken = await TokenService.getRefreshToken();

      // Chưa đăng nhập
      if (refreshToken == null || refreshToken.isEmpty) {
        _goToLogin();
        return;
      }

      // Có refresh token → refresh token
      await AuthRepository.refreshToken();

      // Refresh thành công → vào AppShell
      _goToHome();
    } catch (e) {
      // Refresh thất bại → xóa token
      await TokenService.clearTokens();

      // Quay lại Login
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _goToHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AppShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}