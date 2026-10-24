import 'package:momo_baby_healthcare_flutter/models/auth/user.dart';

class RegisterResponse {
  final String token;
  final String refreshToken;
  final User user;

  RegisterResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }
}
