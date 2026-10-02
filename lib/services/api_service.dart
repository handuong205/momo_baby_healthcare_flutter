import 'package:dio/dio.dart';
import 'package:momo_baby_healthcare_flutter/config/app_config.dart';

import '../exceptions/api_exception.dart';
import 'token_service.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static void initialize() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] ?? true;

          if (!requiresAuth) {
            handler.next(options);
            return;
          }

          final token = await TokenService.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  // GET request
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      return await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  static Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle DioException and convert it to ApiException
  static ApiException _handleError(DioException e) {
    final response = e.response;

    if (response != null && response.data is Map) {
      final data = Map<String, dynamic>.from(response.data);

      final message = data['message']?.toString() ?? 'Đã xảy ra lỗi.';

      final errors = data['errors'] is List
          ? List<String>.from((data['errors'] as List).map((e) => e.toString()))
          : <String>[];

      final errorCode = data['errorCode']?.toString();

      return ApiException(
        message: message,
        errors: errors,
        errorCode: errorCode,
        statusCode: response.statusCode,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiException(message: 'Không thể kết nối đến server.');
    }

    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(message: 'Request đã quá thời gian chờ.');
    }

    return ApiException(
      message: 'Đã xảy ra lỗi không xác định.',
      statusCode: response?.statusCode,
    );
  }
}
