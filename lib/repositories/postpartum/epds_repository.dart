import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

/// EPDS lưu ở backend, gói miễn phí sẽ bị chặn với thông báo nâng cấp gói.
class EpdsRepository {
  EpdsRepository._();

  static const _path = '/api/postpartum/epds';

  /// Gửi 10 câu trả lời (mỗi câu 0–3 điểm).
  static Future<EpdsAssessment?> submit(List<int> answers) async {
    final response = await ApiService.post(_path, data: {'answers': answers});
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return data == null ? null : EpdsAssessment.fromJson(data);
  }

  /// Lần đánh giá gần nhất, `null` khi mẹ chưa làm lần nào.
  static Future<EpdsAssessment?> latest() async {
    final response = await ApiService.get('$_path/latest');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return data == null ? null : EpdsAssessment.fromJson(data);
  }
}
