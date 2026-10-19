import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class PregnancyRepository {
  /// POST /api/pregnancy/setup, giống `profileService.setupPregnancy` bên RN.
  /// [dueDate] để null thì backend tự tính từ ngày kinh cuối.
  static Future<String> setupPregnancy({
    required DateTime lastMenstrualPeriod,
    DateTime? dueDate,
  }) async {
    final response = await ApiService.post(
      '/api/pregnancy/setup',
      data: {
        'lastMenstrualPeriod': _toUtcDateIso(lastMenstrualPeriod),
        'dueDate': dueDate != null ? _toUtcDateIso(dueDate) : null,
      },
    );

    final body = Map<String, dynamic>.from(response.data as Map);

    if (body['success'] != true && body['isSuccess'] != true) {
      throw Exception(body['message'] ?? 'Không thể thiết lập thai kỳ');
    }

    return body['message'] as String? ?? '';
  }

  /// Ngày lịch -> ISO 00:00 UTC, cùng cách với `toUtcDateIso` bên RN.
  static String _toUtcDateIso(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }
}
