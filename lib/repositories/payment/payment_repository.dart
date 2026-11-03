import 'package:momo_baby_healthcare_flutter/models/payment/payment_models.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class PaymentRepository {
  /// Số đơn đang chờ gần nhất được kiểm tra lại khi mở màn gói/lịch sử.
  static const int _pendingToReconcile = 3;

  /// POST /api/payment/create — tạo đơn chuyển khoản VietQR, giống bản web.
  static Future<PaymentOrder> createBankTransfer(String planCode) async {
    final response = await ApiService.post(
      '/api/payment/create',
      data: {'planCode': planCode, 'provider': 'BankTransfer'},
    );
    return PaymentOrder.fromJson(
      _data(response.data, 'Không tạo được đơn thanh toán.'),
    );
  }

  /// GET /api/payment/status/{orderCode}
  ///
  /// Với chuyển khoản, chính lời gọi này khiến backend đối soát sao kê và
  /// kích hoạt gói — nên phải gọi lại khi mẹ quay về từ app ngân hàng.
  static Future<PaymentStatusInfo> getStatus(String orderCode) async {
    final response = await ApiService.get(
      '/api/payment/status/${Uri.encodeComponent(orderCode)}',
      // Backend phải gọi sang SePay nên có thể chậm; cùng mức 60 giây với bản web.
      timeout: const Duration(seconds: 60),
    );
    return PaymentStatusInfo.fromJson(
      _data(response.data, 'Không kiểm tra được trạng thái thanh toán.'),
    );
  }

  /// GET /api/payment/history, kèm đối soát các đơn chuyển khoản còn đang chờ:
  /// mẹ có thể chuyển tiền xong rồi thoát màn thanh toán trước khi app kịp kiểm tra.
  static Future<PaymentHistory> getHistory() async {
    final history = await _fetchHistory();

    final pending = history.transactions
        .where(
          (t) =>
              t.status == PaymentStatus.pending &&
              t.paymentMethod.toLowerCase() == 'banktransfer',
        )
        .take(_pendingToReconcile);

    var activated = false;
    for (final txn in pending) {
      try {
        final info = await getStatus(txn.orderCode);
        activated = activated || info.status == PaymentStatus.completed;
      } catch (_) {
        // Không kiểm tra được thì vẫn hiện lịch sử, lần mở sau kiểm tra lại
      }
    }
    if (!activated) return history;

    await refreshTierClaim();
    return _fetchHistory();
  }

  /// Backend đọc gói từ claim trong JWT: phải lấy token mới sau khi kích hoạt.
  /// Lỗi ở đây không làm hỏng thanh toán vì gói đã lưu ở backend.
  static Future<void> refreshTierClaim() async {
    try {
      await ApiService.refreshSession();
    } catch (_) {}
  }

  static Future<PaymentHistory> _fetchHistory() async {
    final response = await ApiService.get('/api/payment/history');
    return PaymentHistory.fromJson(
      _data(response.data, 'Không tải được lịch sử gói.'),
    );
  }

  static Map<String, dynamic> _data(Object? raw, String fallbackMessage) {
    final body = Map<String, dynamic>.from(raw as Map);
    if (body['success'] != true || body['data'] is! Map) {
      throw Exception(body['message'] ?? fallbackMessage);
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }
}
