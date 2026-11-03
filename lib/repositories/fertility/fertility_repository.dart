import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/models/fertility/fertility_models.dart';
import 'package:momo_baby_healthcare_flutter/models/information/pre_pregnancy/pre_pregnancy_request.dart';
import 'package:momo_baby_healthcare_flutter/models/information/pre_pregnancy/pre_pregnancy_response.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class FertilityRepository {
  FertilityRepository._();

  static const _path = '/api/fertility';

  static Future<PrePregnancyResponse> save(PrePregnancyRequest request) async {
    final response = await ApiService.post(
      '$_path/cycle-log',
      data: request.toJson(),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return PrePregnancyResponse.fromJson(data);
  }

  /// Lịch dự đoán của một tháng (`month` dạng `yyyy-MM`).
  static Future<FertilityCalendar> calendar(DateTime month) async {
    final response = await ApiService.get(
      '$_path/calendar',
      queryParameters: {
        'month':
            '${month.year.toString().padLeft(4, '0')}-'
            '${month.month.toString().padLeft(2, '0')}',
      },
    );
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return FertilityCalendar.fromJson(data ?? const {});
  }

  static Future<OvulationStatus> ovulationToday() async {
    final response = await ApiService.get('$_path/ovulation-today');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return OvulationStatus.fromJson(data ?? const {});
  }
}
