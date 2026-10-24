import 'dart:convert';

/// Trạng thái duyệt của công thức AI (chuyên gia duyệt trên web).
enum RecipeReviewStatus { pending, approved, rejected }

RecipeReviewStatus _parseStatus(Object? raw) {
  switch (raw?.toString().toLowerCase()) {
    case 'approved':
    case '1':
      return RecipeReviewStatus.approved;
    case 'rejected':
    case '2':
      return RecipeReviewStatus.rejected;
    default:
      return RecipeReviewStatus.pending;
  }
}

/// Công thức món ăn cho mẹ.
///
/// Có 2 nguồn:
/// - [MomRecipe.fromDb]: bản ghi trong `/api/recipes/my` (có id, lưu được).
/// - [MomRecipe.fromAi]: phần tử trong chuỗi `recipesJson` vừa tạo (chưa có id).
class MomRecipe {
  final int? id;
  final String title;
  final String description;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int prepTimeMinutes;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final bool isSaved;
  final RecipeReviewStatus status;
  final DateTime? createdAt;

  const MomRecipe({
    this.id,
    required this.title,
    this.description = '',
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.prepTimeMinutes = 0,
    this.difficulty = 'Dễ',
    this.ingredients = const [],
    this.steps = const [],
    this.isSaved = false,
    this.status = RecipeReviewStatus.pending,
    this.createdAt,
  });

  static const _difficultyVi = {
    'easy': 'Dễ',
    'medium': 'Trung bình',
    'hard': 'Khó',
  };

  /// Lấy số từ 20 / "20g" / "20 phút" -> 20
  static double _num(Object? v) {
    if (v is num) return v.toDouble();
    final match = RegExp(r'[\d]+([.,]\d+)?').firstMatch(v?.toString() ?? '');
    return double.tryParse(match?.group(0)?.replaceAll(',', '.') ?? '') ?? 0;
  }

  static List<String> _list(Object? v) {
    Object? value = v;
    if (value is String) {
      try {
        value = jsonDecode(value);
      } catch (_) {
        return [];
      }
    }
    if (value is! List) return [];
    return value
        .map((e) => e is Map ? (e['name'] ?? e['instruction'] ?? '').toString() : e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  factory MomRecipe.fromDb(Map<String, dynamic> json) {
    final diff = json['difficulty']?.toString() ?? '';
    return MomRecipe(
      id: (json['id'] as num?)?.toInt(),
      title: json['title']?.toString() ?? 'Món ăn',
      description: json['description']?.toString() ?? '',
      calories: _num(json['calories']).round(),
      protein: _num(json['protein']),
      carbs: _num(json['carbs']),
      fat: _num(json['fat']),
      prepTimeMinutes: _num(json['prepTimeMinutes']).round(),
      difficulty: _difficultyVi[diff.toLowerCase()] ?? (diff.isEmpty ? 'Dễ' : diff),
      ingredients: _list(json['ingredientsJson']),
      steps: _list(json['stepsJson']),
      isSaved: json['isSaved'] == true,
      status: _parseStatus(json['status']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
    );
  }

  factory MomRecipe.fromAi(Map<String, dynamic> json) {
    final diff = json['difficulty']?.toString() ?? '';
    return MomRecipe(
      title: (json['recipe'] ?? json['title'] ?? 'Món ăn AI').toString(),
      calories: _num(json['calories']).round(),
      protein: _num(json['protein']),
      carbs: _num(json['carbs']),
      fat: _num(json['fat']),
      prepTimeMinutes: _num(json['prepTime']).round(),
      difficulty: _difficultyVi[diff.toLowerCase()] ?? (diff.isEmpty ? 'Dễ' : diff),
      ingredients: _list(json['ingredients']),
      steps: _list(json['steps']),
    );
  }

  MomRecipe copyWith({bool? isSaved}) {
    return MomRecipe(
      id: id,
      title: title,
      description: description,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      prepTimeMinutes: prepTimeMinutes,
      difficulty: difficulty,
      ingredients: ingredients,
      steps: steps,
      isSaved: isSaved ?? this.isSaved,
      status: status,
      createdAt: createdAt,
    );
  }
}

/// Hồ sơ dinh dưỡng của mẹ (`/api/recipes/profiles/current`).
class NutritionProfile {
  final String stage;
  final String description;

  const NutritionProfile({required this.stage, required this.description});

  factory NutritionProfile.fromJson(Map<String, dynamic> json) {
    return NutritionProfile(
      stage: json['profileId']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
    );
  }

  String get stageLabel {
    switch (stage) {
      case 'PrePregnancy':
        return 'Chuẩn bị mang thai';
      case 'Pregnancy':
      case 'Pregnant':
        return 'Đang mang thai';
      case 'Postpartum':
        return 'Sau sinh';
      default:
        return 'Chưa thiết lập giai đoạn';
    }
  }
}
