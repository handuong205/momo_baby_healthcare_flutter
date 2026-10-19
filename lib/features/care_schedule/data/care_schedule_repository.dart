import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../models/care_schedule.dart';

/// Lịch chăm sóc dùng chung API lịch nhắc của backend (`/api/medications`):
/// backend lưu lịch, ghi trạng thái từng ngày và tạo thông báo khi tới giờ.
class CareScheduleRepository {
  CareScheduleRepository(this.client);

  final ApiClient client;

  Future<List<CareSchedule>> list() async {
    final response = await client.dio.get(ApiConfig.medications);
    final data = unwrapApiData<List<dynamic>>(response.data) ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CareSchedule.fromJson)
        .toList();
  }

  Future<void> add({
    required String name,
    required String dosage,
    required List<String> times,
    required DateTime startDate,
    required int durationDays,
    String? notes,
  }) async {
    final response = await client.dio.post(
      ApiConfig.medications,
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

  Future<void> delete(int id) async {
    final response = await client.dio.delete(ApiConfig.medicationById(id));
    unwrapApiData<Object>(response.data);
  }

  Future<void> mark(int id, DateTime day, AdherenceStatus status) async {
    final response = await client.dio.post(
      ApiConfig.medicationAdherence(id),
      data: {'date': toUtcDateIso(day), 'status': status.name},
    );
    unwrapApiData<Object>(response.data);
  }
}
