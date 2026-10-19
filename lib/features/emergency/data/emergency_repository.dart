import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';

/// Tiền tố đánh dấu cảnh báo do màn Khẩn cấp tạo, để lọc ra khỏi các cảnh báo
/// khác trong `/api/alerts` (backend không có loại "Emergency" riêng).
const emergencyMarker = '🚨';

/// Một lần mẹ ghi nhận khẩn cấp, từ `GET /api/alerts`.
class EmergencyEvent {
  const EmergencyEvent({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.resolved,
  });

  final int id;
  final String message;
  final DateTime? createdAt;
  final bool resolved;

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) => EmergencyEvent(
    id: (json['id'] as num).toInt(),
    message: json['message']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')
        ?.toLocal(),
    resolved: json['status']?.toString().toLowerCase() == 'resolved',
  );
}

/// Ghi lại sự kiện khẩn cấp vào hệ thống cảnh báo của backend (`/api/alerts`)
/// để lịch sử hiện trong màn Khẩn cấp và mục Thông báo.
class EmergencyRepository {
  EmergencyRepository(this.client);

  final ApiClient client;

  Future<void> report(String message) async {
    final response = await client.dio.post(
      ApiConfig.alerts,
      data: {
        'type': 'Symptom',
        'message': message.startsWith(emergencyMarker)
            ? message
            : '$emergencyMarker $message',
        'channels': ['app'],
      },
    );
    unwrapApiData<Object>(response.data);
  }

  /// Các lần ghi nhận khẩn cấp gần nhất (mới nhất trước).
  Future<List<EmergencyEvent>> history() async {
    final response = await client.dio.get(ApiConfig.alerts);
    final data = unwrapApiData<List<dynamic>>(response.data) ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .where(
          (a) => a['message']?.toString().startsWith(emergencyMarker) ?? false,
        )
        .map(EmergencyEvent.fromJson)
        .toList();
  }

  /// Mẹ xác nhận đã an toàn → đánh dấu cảnh báo là đã xử lý.
  Future<void> resolve(int id) async {
    final response = await client.dio.patch(
      ApiConfig.alertStatus(id),
      data: {'status': 'Resolved'},
    );
    unwrapApiData<Object>(response.data);
  }
}
