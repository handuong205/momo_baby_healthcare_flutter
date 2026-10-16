import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this.client, this.storage);

  final ApiClient client;
  final SecureStorageService storage;

  Future<UserModel?> restoreSession() async {
    final token = await storage.read(SecureStorageService.tokenKey);
    final rawUser = await storage.read(SecureStorageService.userKey);
    if (token == null || token.isEmpty || rawUser == null) return null;
    return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
  }

  Future<UserModel> login(String email, String password) async {
    final response = await client.dio.post(
      ApiConfig.login,
      data: {'email': email, 'password': password},
    );
    final data = _successData(response.data);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await storage.saveSession(
      token: data['token'] as String,
      refreshToken: data['refreshToken'] as String?,
      user: user.toJson(),
      tier: mapTier(user.tier),
    );
    return user;
  }

  Future<String?> register(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await client.dio.post(
      ApiConfig.register,
      data: {'email': email, 'password': password, 'fullName': fullName},
    );
    final body = _body(response.data);
    if (!_isSuccess(body)) {
      throw Exception(body['message'] ?? 'Đăng ký thất bại.');
    }
    return body['message'] as String?;
  }

  Future<void> logout() async {
    final refreshToken = await storage.read(
      SecureStorageService.refreshTokenKey,
    );
    try {
      await client.dio.post(
        ApiConfig.logout,
        data: refreshToken == null || refreshToken.isEmpty
            ? null
            : {'refreshToken': refreshToken},
      );
    } on DioException catch (error) {
      debugPrint('[AuthRepository] logout failed: ${error.message}');
    } finally {
      await storage.clearSession();
    }
  }

  static Map<String, dynamic> _body(dynamic value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  static bool _isSuccess(Map<String, dynamic> body) =>
      body['success'] == true || body['isSuccess'] == true;

  static Map<String, dynamic> _successData(dynamic value) {
    final body = _body(value);
    if (!_isSuccess(body) || body['data'] is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: RequestOptions(),
        message: body['message'] as String? ?? 'Đăng nhập không thành công.',
        response: Response(requestOptions: RequestOptions(), data: body),
      );
    }
    return body['data'] as Map<String, dynamic>;
  }
}
