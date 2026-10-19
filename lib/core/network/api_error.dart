import 'package:dio/dio.dart';

const _networkMessage =
    'Không kết nối được máy chủ. Mẹ kiểm tra mạng và thử lại nhé.';

String? _firstString(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value;
  if (value is List) {
    for (final item in value) {
      final found = _firstString(item);
      if (found != null) return found;
    }
  }
  if (value is Map) {
    for (final item in value.values) {
      final found = _firstString(item);
      if (found != null) return found;
    }
  }
  return null;
}

/// Thông báo lỗi dễ hiểu từ backend, cùng cách đọc với `getApiErrorMessage`
/// của app Mobile: ApiResponse `{ message }`, middleware `{ Message }` và
/// ProblemDetails `{ title, errors }`.
String apiErrorMessage(
  Object error, [
  String fallback = 'Đã có lỗi xảy ra. Mẹ thử lại sau nhé.',
]) {
  if (error is DioException) {
    final response = error.response;
    if (response == null) return _networkMessage;
    final data = response.data;
    if (data is Map) {
      final message =
          _firstString(data['message'] ?? data['Message']) ??
          _firstString(data['errors'] ?? data['Errors']);
      if (message != null) return message;
      if (data['title'] is String) return data['title'] as String;
    }
    return fallback;
  }
  if (error is ApiFailure) return error.message;
  return fallback;
}

/// Backend trả HTTP 200 nhưng `success: false`.
class ApiFailure implements Exception {
  const ApiFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Lấy `data` của ApiResponse, ném [ApiFailure] khi `success == false`.
T? unwrapApiData<T>(Object? body) {
  if (body is Map<String, dynamic> &&
      (body.containsKey('success') || body.containsKey('isSuccess'))) {
    if (body['success'] == false || body['isSuccess'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Thao tác không thành công.',
      );
    }
    final data = body['data'];
    return data is T ? data : null;
  }
  return body is T ? body : null;
}
