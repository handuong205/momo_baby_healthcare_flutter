class UserProfile {
  final String userId;
  final String stage;
  final int? pregnancyWeek;
  final double? bmi;
  final double? height;
  final double? weight;
  final double? bloodSugarLevel;
  final bool hasGestDiabetes;
  final String? medicalConditions;
  final int? avgCycleLength;
  final String? lastPeriodDate;
  final String? deliveryDate;
  final bool isBreastfeeding;
  final List<dynamic> cycleLogs;
  final List<dynamic> epdsAssessments;
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  UserProfile({
    required this.userId,
    required this.stage,
    this.pregnancyWeek,
    this.bmi,
    this.height,
    this.weight,
    this.bloodSugarLevel,
    required this.hasGestDiabetes,
    this.medicalConditions,
    this.avgCycleLength,
    this.lastPeriodDate,
    this.deliveryDate,
    required this.isBreastfeeding,
    required this.cycleLogs,
    required this.epdsAssessments,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.deletedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      stage: json['stage'] as String,
      pregnancyWeek: (json['pregnancyWeek'] as num?)?.toInt(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodSugarLevel: (json['bloodSugarLevel'] as num?)?.toDouble(),
      hasGestDiabetes: json['hasGestDiabetes'] as bool? ?? false,
      medicalConditions: json['medicalConditions'] as String?,
      avgCycleLength: (json['avgCycleLength'] as num?)?.toInt(),
      lastPeriodDate: json['lastPeriodDate'] as String?,
      deliveryDate: json['deliveryDate'] as String?,
      isBreastfeeding: json['isBreastfeeding'] as bool? ?? false,
      cycleLogs: (json['cycleLogs'] as List<dynamic>?) ?? [],
      epdsAssessments: (json['epdsAssessments'] as List<dynamic>?) ?? [],
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }
}
