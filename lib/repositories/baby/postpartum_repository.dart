import 'package:momo_baby_healthcare_flutter/models/baby/baby_profile_response.dart';
import 'package:momo_baby_healthcare_flutter/models/baby/postpartum_setup_response.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class PostpartumRepository {
  /// [gender]: 0 = bé trai, 1 = bé gái (giống `toBabyPayload` bên RN).
  static Future<BabyProfileResponse> saveBabyProfile({
    required DateTime dateOfBirth,
    required int gender,
    required String babyName,
    double? currentWeightKg,
    double? currentHeightCm,
    List<String> allergies = const [],
  }) async {
    final response = await ApiService.post(
      '/api/baby/profile',
      data: {
        'babyName': babyName,
        'dateOfBirth': DateTime.utc(
          dateOfBirth.year,
          dateOfBirth.month,
          dateOfBirth.day,
        ).toIso8601String(),
        'gender': gender,
        'currentWeightKg': currentWeightKg,
        'currentHeightCm': currentHeightCm,
        'allergies': allergies,
        'foodHistory': <String>[],
      },
      requiresAuth: true,
    );

    final body = Map<String, dynamic>.from(response.data as Map);

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể tạo hồ sơ cho bé');
    }

    return BabyProfileResponse.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }

  /// [deliveryType]: 'natural' (sinh thường) hoặc 'cesarean' (sinh mổ), giống RN.
  static Future<PostpartumSetupResponse> setupPostpartum({
    required DateTime deliveryDate,
    required String deliveryType,
    required bool isBreastfeeding,
  }) async {
    final response = await ApiService.post(
      '/api/postpartum/setup',
      data: {
        'deliveryDate': DateTime.utc(
          deliveryDate.year,
          deliveryDate.month,
          deliveryDate.day,
        ).toIso8601String(),
        'deliveryType': deliveryType,
        'isBreastfeeding': isBreastfeeding,
      },
      requiresAuth: true,
    );

    final body = Map<String, dynamic>.from(response.data as Map);

    if (body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Không thể thiết lập trạng thái sau sinh',
      );
    }

    return PostpartumSetupResponse.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
      message: body['message'] as String? ?? '',
    );
  }
}
