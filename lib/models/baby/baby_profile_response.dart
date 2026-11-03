
class BabyProfileResponse {
  final int id;
  final String userId;
  final String babyName;
  final String dateOfBirth;
  final String gender;
  final double? currentWeightKg;
  final double? currentHeightCm;
  final int ageMonths;
  final List<String> allergies;

  const BabyProfileResponse({
    required this.id,
    required this.userId,
    required this.babyName,
    required this.dateOfBirth,
    required this.gender,
    this.currentWeightKg,
    this.currentHeightCm,
    required this.ageMonths,
    required this.allergies,
  });

  factory BabyProfileResponse.fromJson(Map<String, dynamic> json) {
    return BabyProfileResponse(
      id: json['id'] as int,
      userId: json['userId'] as String,
      babyName: json['babyName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      gender: json['gender'] as String,
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      currentHeightCm: (json['currentHeightCm'] as num?)?.toDouble(),
      ageMonths: json['ageMonths'] as int,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }
}
