class UserModel {
  const UserModel({this.id, required this.email, this.fullName, this.tier});

  final String? id;
  final String email;
  final String? fullName;
  final Object? tier;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString(),
    email: json['email'] as String? ?? '',
    fullName: json['fullName'] as String?,
    tier: json['tier'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'email': email,
    if (fullName != null) 'fullName': fullName,
    if (tier != null) 'tier': tier,
  };
}

String mapTier(Object? value) {
  if (value == 1 || value == 'MomHienDai') return 'MomHienDai';
  if (value == 2 || value == 'SuperMomVip') return 'SuperMomVip';
  return 'Free';
}
