import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/models/notification/notification_alert.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class NotificationRepository {
  NotificationRepository._();

  static const _path = '/api/alerts';

  static Future<List<NotificationAlert>> list() async {
    final response = await ApiService.get(_path);
    final data = unwrapApiData<List<dynamic>>(response.data) ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(NotificationAlert.fromJson)
        .toList();
  }

  /// Dùng `/status` (có kiểm tra chủ sở hữu) thay cho `/resolve`: `/resolve`
  /// không kiểm tra người gọi và đóng cả cảnh báo trùng id ở bảng khác.
  static Future<void> markResolved(int id) async {
    final response = await ApiService.patch(
      '$_path/$id/status',
      data: {'status': 'Resolved'},
    );
    unwrapApiData<Object>(response.data);
  }
}
