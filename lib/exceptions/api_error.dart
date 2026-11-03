import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';

class ApiError {
  static String getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
  }
}