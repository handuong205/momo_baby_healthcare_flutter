import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/models/pregnancy/pregnancy_models.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class PregnancyRepository {
  PregnancyRepository._();

  static const _path = '/api/pregnancy';

  /// POST /api/pregnancy/setup, giống `profileService.setupPregnancy` bên RN.
  /// [dueDate] để null thì backend tự tính từ ngày kinh cuối.
  static Future<PregnancySetupResult> setup({
    required DateTime lastMenstrualPeriod,
    DateTime? dueDate,
  }) async {
    final response = await ApiService.post(
      '$_path/setup',
      data: {
        'lastMenstrualPeriod': _toUtcDateIso(lastMenstrualPeriod),
        'dueDate': dueDate != null ? _toUtcDateIso(dueDate) : null,
      },
    );

    final body = Map<String, dynamic>.from(response.data as Map);
    final data = unwrapApiData<Map<String, dynamic>>(body) ?? const {};
    return PregnancySetupResult.fromJson(data);
  }

  /// `GET /api/pregnancy/this-week` — tuần thai hiện tại của mẹ.
  static Future<PregnancyWeekInfo> thisWeek() async {
    final response = await ApiService.get('$_path/this-week');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return PregnancyWeekInfo.fromJson(data ?? const {});
  }

  /// `GET /api/pregnancy/today-steps` — số bước chân hôm nay.
  static Future<int> todaySteps() async {
    final response = await ApiService.get('$_path/today-steps');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return (data?['todaySteps'] as num?)?.toInt() ?? 0;
  }

  /// Ngày lịch -> ISO 00:00 UTC, cùng cách với `toUtcDateIso` bên RN.
  static String _toUtcDateIso(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }
}
