import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/models/care/care_schedule.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

/// Lịch chăm sóc dùng chung API lịch nhắc của backend (`/api/medications`):
/// backend lưu lịch, ghi trạng thái từng ngày và tạo thông báo khi tới giờ.
class CareScheduleRepository {
  CareScheduleRepository._();

  static const _path = '/api/medications';

  static Future<List<CareSchedule>> list() async {
    final response = await ApiService.get(_path);
    final data = unwrapApiData<List<dynamic>>(response.data) ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CareSchedule.fromJson)
        .toList();
  }

  static Future<void> add({
    required String name,
    required String dosage,
    required List<String> times,
    required DateTime startDate,
    required int durationDays,
    String? notes,
  }) async {
    final response = await ApiService.post(
      _path,
      data: {
        'medName': name,
        'dosage': dosage,
        'times': times,
        'startDate': toUtcDateIso(startDate),
        'endDate': toUtcDateIso(startDate.add(Duration(days: durationDays))),
        'notes': ?notes,
      },
    );
    unwrapApiData<Object>(response.data);
  }

  static Future<void> delete(int id) async {
    final response = await ApiService.delete('$_path/$id');
    unwrapApiData<Object>(response.data);
  }

  static Future<void> mark(int id, DateTime day, AdherenceStatus status) async {
    final response = await ApiService.post(
      '$_path/$id/adherence',
      data: {'date': toUtcDateIso(day), 'status': status.name},
    );
    unwrapApiData<Object>(response.data);
  }
}
