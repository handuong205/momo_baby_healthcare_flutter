

import 'package:momo_baby_healthcare_flutter/models/user/user_profile.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class UserProfileRepository{
  static Future <UserProfile> getUserProfile() async {
    final response = await ApiService.get('/api/user-profile');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(response.data);
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}