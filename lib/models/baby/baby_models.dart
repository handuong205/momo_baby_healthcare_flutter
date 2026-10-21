class GrowthRecord {
  final int id;
  final DateTime recordedAt;
  final double weightKg;
  final double heightCm;

  const GrowthRecord({
    required this.id,
    required this.recordedAt,
    required this.weightKg,
    required this.heightCm,
  });

  factory GrowthRecord.fromJson(Map<String, dynamic> json) => GrowthRecord(
        id: _int(json['id']),
        recordedAt: DateTime.tryParse(
              '${json['recordedAt'] ?? json['date'] ?? ''}',
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        weightKg: _double(json['weightKg'] ?? json['weight_kg']),
        heightCm: _double(json['heightCm'] ?? json['height_cm']),
      );
}

class BabyProfile {
  final int id;
  final String userId;
  final String babyName;
  final DateTime dateOfBirth;
  final String gender;
  final double? currentWeightKg;
  final double? currentHeightCm;
  final int ageMonths;
  final List<String> allergies;
  final List<String> foodHistory;
  final List<GrowthRecord> growthRecords;

  const BabyProfile({
    required this.id,
    required this.userId,
    required this.babyName,
    required this.dateOfBirth,
    required this.gender,
    required this.currentWeightKg,
    required this.currentHeightCm,
    required this.ageMonths,
    required this.allergies,
    required this.foodHistory,
    required this.growthRecords,
  });

  bool get isBoy =>
      gender.toLowerCase() == 'male' ||
      gender.toLowerCase() == 'boy' ||
      gender == '0';

  factory BabyProfile.fromJson(Map<String, dynamic> json) => BabyProfile(
        id: _int(json['id']),
        userId: '${json['userId'] ?? json['user_id'] ?? ''}',
        babyName: '${json['babyName'] ?? json['baby_name'] ?? ''}',
        dateOfBirth: DateTime.tryParse(
              '${json['dateOfBirth'] ?? json['date_of_birth'] ?? ''}',
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        gender: _gender(json['gender']),
        currentWeightKg: _nullableDouble(
          json['currentWeightKg'] ?? json['current_weight_kg'],
        ),
        currentHeightCm: _nullableDouble(
          json['currentHeightCm'] ?? json['current_height_cm'],
        ),
        ageMonths: _int(json['ageMonths'] ?? json['age_months']),
        allergies: _strings(json['allergies']),
        foodHistory: _strings(json['foodHistory'] ?? json['food_history']),
        growthRecords: _growthList(
          json['growthRecords'] ?? json['growth_records'],
        ),
      );
}

class GrowthEvaluation {
  final bool isHealthy;
  final String weightStatus;
  final String heightStatus;
  final String feedback;

  const GrowthEvaluation({
    required this.isHealthy,
    required this.weightStatus,
    required this.heightStatus,
    required this.feedback,
  });

  factory GrowthEvaluation.fromJson(Map<String, dynamic> json) =>
      GrowthEvaluation(
        isHealthy: json['isHealthy'] == true || json['is_healthy'] == true,
        weightStatus:
            '${json['weightStatus'] ?? json['weight_status'] ?? ''}',
        heightStatus:
            '${json['heightStatus'] ?? json['height_status'] ?? ''}',
        feedback: '${json['feedback'] ?? ''}',
      );
}

class MealItem {
  final String name;
  final String description;
  final String texture;
  final int prepTimeMin;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final List<String> allergens;

  const MealItem({
    required this.name,
    required this.description,
    required this.texture,
    required this.prepTimeMin,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.allergens,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
        name: '${json['name_vi'] ?? json['name'] ?? json['name_en'] ?? ''}',
        description: '${json['description'] ?? ''}',
        texture: '${json['texture'] ?? ''}',
        prepTimeMin: _int(json['prep_time_min']),
        calories: _double(json['total_calories']),
        protein: _double(json['protein_g'] ?? json['total_protein_g']),
        fat: _double(json['fat_g'] ?? json['total_fat_g']),
        carbs: _double(json['carbs_g'] ?? json['total_carbs_g']),
        allergens: _strings(json['allergens']),
      );
}

class DailyMenu {
  final Map<String, MealItem?> meals;
  final Map<String, double> nutritionTotals;
  final Map<String, double> coverage;
  final Map<String, double> goals;
  final bool meets80Pct;

  const DailyMenu({
    required this.meals,
    required this.nutritionTotals,
    required this.coverage,
    required this.goals,
    required this.meets80Pct,
  });

  factory DailyMenu.fromJson(Map<String, dynamic> json) => DailyMenu(
        meals: _mealMap(json['meals']),
        nutritionTotals: _numberMap(json['nutrition_totals']),
        coverage: _numberMap(json['coverage_pct']),
        goals: _numberMap(json['goals']),
        meets80Pct: json['meets_80pct'] == true || json['meets80pct'] == true,
      );
}

class WeeklyMenu {
  final List<DailyMenu> days;

  const WeeklyMenu({required this.days});

  factory WeeklyMenu.fromJson(Map<String, dynamic> json) => WeeklyMenu(
        days: (json['days'] as List? ?? [])
            .whereType<Map>()
            .map((item) => DailyMenu.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
}

int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
double? _nullableDouble(dynamic value) => value == null ? null : _double(value);
String _gender(dynamic value) {
  if (value is num) return value.toInt() == 0 ? 'Male' : 'Female';
  final text = '$value';
  return text.toLowerCase() == 'boy' ? 'Male' : text;
}
List<String> _strings(dynamic value) =>
    value is List ? value.map((item) => '$item').toList() : const [];
Map<String, double> _numberMap(dynamic value) => value is Map
    ? value.map((key, item) => MapEntry('$key', _double(item)))
    : const {};
Map<String, MealItem?> _mealMap(dynamic value) => value is Map
    ? value.map((key, item) => MapEntry(
          '$key',
          item is Map ? MealItem.fromJson(Map<String, dynamic>.from(item)) : null,
        ))
    : const {};
List<GrowthRecord> _growthList(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => GrowthRecord.fromJson(Map<String, dynamic>.from(item)))
        .toList()
    : const [];
