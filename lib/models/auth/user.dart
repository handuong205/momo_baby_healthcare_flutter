class User {
  final String id;
  final String email;
  final String tier;
  final List<String> roles;

  User({
    required this.id,
    required this.email,
    required this.tier,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      tier: json['tier'] as String,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}