import 'package:momo_baby_healthcare_flutter/models/information/pre_pregnancy/pre_pregnancy_request.dart';
import 'package:momo_baby_healthcare_flutter/models/information/pre_pregnancy/pre_pregnancy_response.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class FertilityRepository {
  static Future<PrePregnancyResponse> save(PrePregnancyRequest request) async {
    final response = await ApiService.post(
      '/api/fertility/cycle-log',
      data: request.toJson(),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return PrePregnancyResponse.fromJson(data);
  }
}
