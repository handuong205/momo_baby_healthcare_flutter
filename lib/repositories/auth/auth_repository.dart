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

    return result;
  }

  static Future<LoginResponse> refreshToken() async {
    final refreshToken = await TokenService.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token không tồn tại');
    }

    final response = await ApiService.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
      requiresAuth: false,
    );

    final data = response.data['data'];

    final result = LoginResponse.fromJson(data as Map<String, dynamic>);

    // Backend cấp token + refreshToken mới
    await TokenService.saveTokens(
      token: result.token,
      refreshToken: result.refreshToken,
    );

    return result;
  }

  static Future<void> logout() async {
    await TokenService.clearTokens();
  }
}
