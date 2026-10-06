import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/models/auth/login_response.dart';
import 'package:momo_baby_healthcare_flutter/repositories/auth/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/login_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/home/home_screen.dart';
import 'package:momo_baby_healthcare_flutter/services/token_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final refreshToken =
          await TokenService.getRefreshToken();

      // Không có refresh token
      // => chưa đăng nhập
      if (refreshToken == null ||
          refreshToken.isEmpty) {
        _goToLogin();
        return;
      }

      // Có refresh token
      // => gọi backend để lấy token mới
      final result =
          await AuthRepository.refreshToken();

      // Refresh thành công
      _goToHome(result);
    } catch (e) {
      // Refresh thất bại
      // => xóa token và bắt đăng nhập lại
      await TokenService.clearTokens();

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

  void _goToHome(LoginResponse result) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
         
        ),
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