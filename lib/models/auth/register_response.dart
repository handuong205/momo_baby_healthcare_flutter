class RegisterResponse {
  final String token;
  final String refreshToken;
  final RegisterUser user;

  RegisterResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: RegisterUser.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }
}

class RegisterUser {
  final String id;
  final String email;
  final String tier;
  final List<String> roles;

  RegisterUser({
    required this.id,
    required this.email,
    required this.tier,
    required this.roles,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      id: json['id'] as String,
      email: json['email'] as String,
      tier: json['tier'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }
}