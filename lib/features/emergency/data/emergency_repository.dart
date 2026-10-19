import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';

/// Ghi lại sự kiện khẩn cấp vào hệ thống cảnh báo của backend (`/api/alerts`)
/// để lịch sử hiện trong Thông báo và Care Staff theo dõi được.
class EmergencyRepository {
  EmergencyRepository(this.client);

  final ApiClient client;

  Future<void> report(String message) async {
    final response = await client.dio.post(
      ApiConfig.alerts,
      data: {
        'type': 'Symptom',
        'message': message,
        'channels': ['app'],
      },
    );
    unwrapApiData<Object>(response.data);
  }
}
