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
      userId: json['user_id'],
      stage: json['stage'],
      pregnancyWeek: json['pregnancy_week'],
      bmi: (json['bmi'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodSugarLevel: (json['blood_sugar_level'] as num?)?.toDouble(),
      hasGestDiabetes: json['has_gest_diabetes'],
      medicalConditions: json['medical_conditions'],
      avgCycleLength: json['avg_cycle_length'],
      lastPeriodDate: json['last_period_date'],
      deliveryDate: json['delivery_date'],
      isBreastfeeding: json['is_breastfeeding'],
      cycleLogs: json['cycle_logs'] ?? [],
      epdsAssessments: json['epds_assessments'] ?? [],
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'],
      deletedAt:
          json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at']) 
          : null,
    );
  }
}