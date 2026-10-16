import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient(this.storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cancelToken = CancelToken();
          options.cancelToken = cancelToken;
          _activeTokens.add(cancelToken);
          final token = await storage.read(SecureStorageService.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.requestOptions.cancelToken != null) {
            _activeTokens.remove(response.requestOptions.cancelToken);
          }
          _normalizeResponse(response.data);
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.requestOptions.cancelToken != null) {
            _activeTokens.remove(error.requestOptions.cancelToken);
          }
          _normalizeResponse(error.response?.data);
          if (error.response?.statusCode != 401 ||
              error.requestOptions.extra['retried'] == true ||
              error.requestOptions.path.startsWith('/api/auth/')) {
            handler.next(error);
            return;
          }

          final refreshToken = await storage.read(
            SecureStorageService.refreshTokenKey,
          );
          if (refreshToken == null || refreshToken.isEmpty) {
            await storage.clearSession();
            await _notifySessionExpired();
            handler.next(error);
            return;
          }

          try {
            final refreshResponse = await Dio(
              BaseOptions(baseUrl: ApiConfig.baseUrl),
            ).post(ApiConfig.refresh, data: {'refreshToken': refreshToken});
            final body = refreshResponse.data as Map<String, dynamic>?;
            final data = body?['data'] as Map<String, dynamic>?;
            final success =
                body?['success'] == true ||
                body?['isSuccess'] == true ||
                body?['Success'] == true;
            if (!success || data == null || data['token'] is! String) {
              await storage.clearSession();
              await _notifySessionExpired();
              handler.next(error);
              return;
            }
            await storage.write(
              SecureStorageService.tokenKey,
              data['token'] as String,
            );
            if (data['refreshToken'] is String) {
              await storage.write(
                SecureStorageService.refreshTokenKey,
                data['refreshToken'] as String,
              );
            }
            if (data['user'] is Map<String, dynamic>) {
              await storage.write(
                SecureStorageService.userKey,
                jsonEncode(data['user']),
              );
            }
            final retryOptions = error.requestOptions
              ..extra['retried'] = true
              ..headers['Authorization'] = 'Bearer ${data['token']}';
            handler.resolve(await dio.fetch(retryOptions));
          } on DioException {
            await storage.clearSession();
            await _notifySessionExpired();
            handler.next(error);
          }
        },
      ),
    );
  }

  final Dio dio;
  final SecureStorageService storage;
  Future<void> Function()? onSessionExpired;
  final Set<CancelToken> _activeTokens = {};
  bool _notifyingExpiry = false;

  Future<void> cancelActiveRequests() async {
    for (final token in List<CancelToken>.from(_activeTokens)) {
      token.cancel('Session ended');
    }
    _activeTokens.clear();
  }

  Future<void> _notifySessionExpired() async {
    if (_notifyingExpiry) return;
    _notifyingExpiry = true;
    try {
      await onSessionExpired?.call();
    } finally {
      _notifyingExpiry = false;
    }
  }

  static void _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['success'] != null && data['isSuccess'] == null) {
        data['isSuccess'] = data['success'];
      } else if (data['isSuccess'] != null && data['success'] == null) {
        data['success'] = data['isSuccess'];
      }
    }
  }
}
