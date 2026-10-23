import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';

/// Lấy `data` của ApiResponse, ném [ApiException] khi backend trả HTTP 200
/// nhưng `success == false`.
T? unwrapApiData<T>(Object? body) {
  if (body is Map<String, dynamic> &&
      (body.containsKey('success') || body.containsKey('isSuccess'))) {
    if (body['success'] == false || body['isSuccess'] == false) {
      throw ApiException(
        message: body['message']?.toString() ?? 'Thao tác không thành công.',
      );
    }
    final data = body['data'];
    return data is T ? data : null;
  }
  return body is T ? body : null;
}
