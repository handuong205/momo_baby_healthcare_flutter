import 'package:momo_baby_healthcare_flutter/models/auth/register_request.dart';

import '/services/token_service.dart';
import '/models/auth/login_request.dart';
import '/models/auth/login_response.dart';
import '/services/api_service.dart';

class AuthRepository {
  static Future<LoginResponse> login(LoginRequest request) async {
    final response = await ApiService.post(
      '/api/auth/login',
      data: request.toJson(),
      requiresAuth: false,
    );

    final data = response.data['data'];

    final result = LoginResponse.fromJson(data as Map<String, dynamic>);

    await TokenService.saveTokens(
      token: result.token,
      refreshToken: result.refreshToken,
    );
    await TokenService.saveUserName(result.user.fullName);

    return result;
  }

  static Future<LoginResponse> register(RegisterRequest request) async {
    final response = await ApiService.post(
      '/api/auth/register',
      data: request.toJson(),
      requiresAuth: false,
    );

    final data = response.data['data'];

    final result = LoginResponse.fromJson(data as Map<String, dynamic>);

    await TokenService.saveTokens(
      token: result.token,
      refreshToken: result.refreshToken,
    );
    await TokenService.saveUserName(result.user.fullName ?? request.fullName);

    return result;
  }

  static Future<LoginResponse> refreshToken() async {
    // Backend cấp token + refreshToken mới, ApiService đã lưu lại.
    final response = await ApiService.refreshSession();

    final data = response.data['data'];

    return LoginResponse.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/api/auth/logout', requiresAuth: true);
    } finally {
      await TokenService.clearTokens();
    }
  }
}
