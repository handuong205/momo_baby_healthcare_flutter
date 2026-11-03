import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/models/user/user_profile.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class UserProfileRepository {
  static const _path = '/api/user-profile';

  /// Các trường `PUT /api/user-profile` ghi vào hồ sơ.
  static const _writableFields = [
    'pregnancyWeek',
    'bmi',
    'height',
    'weight',
    'bloodSugarLevel',
    'hasGestDiabetes',
    'medicalConditions',
    'avgCycleLength',
    'lastPeriodDate',
    'deliveryDate',
    'isBreastfeeding',
  ];

  static Future<Map<String, dynamic>> _getRawProfile() async {
    final response = await ApiService.get(_path);
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    if (data == null) {
      throw Exception('Failed to load user profile');
    }
    return data;
  }

  static Future<UserProfile> getUserProfile() async {
    return UserProfile.fromJson(await _getRawProfile());
  }

  /// Backend ghi đè mọi trường theo body, trường không gửi sẽ thành null (mất
  /// ngày kinh cuối, chu kỳ, chiều cao...). Vì vậy phải đọc hồ sơ hiện tại rồi
  /// gửi lại đủ các trường, chỉ đổi `stage`.
  static Future<UserProfile> chooseStageUserProfile(String stage) async {
    final current = await _getRawProfile();
    final response = await ApiService.put(
      _path,
      data: {
        for (final field in _writableFields) field: current[field],
        'stage': stage,
      },
    );

    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    if (data == null) {
      throw Exception('Failed to update user profile');
    }

    return UserProfile.fromJson(data);
  }
}
