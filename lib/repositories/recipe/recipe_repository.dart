import 'dart:convert';

import 'package:momo_baby_healthcare_flutter/models/recipe/mom_recipe.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

/// Tùy chọn mẹ chọn trước khi nhờ AI gợi ý món.
class RecipePreferences {
  final String dietType;
  final String allergies;
  final int maxCookTime;
  final String availableIngredients;

  const RecipePreferences({
    this.dietType = 'Thường',
    this.allergies = '',
    this.maxCookTime = 30,
    this.availableIngredients = '',
  });

  /// Cùng định dạng câu truy vấn với bản web để AI trả kết quả giống nhau.
  String toQuery() {
    String orNone(String v) => v.trim().isEmpty ? 'Không' : v.trim();
    return 'Chế độ ăn: $dietType, Dị ứng: ${orNone(allergies)}, '
        'Thời gian nấu tối đa: $maxCookTime phút, '
        'Nguyên liệu có sẵn: ${orNone(availableIngredients)}';
  }
}

class RecipeRepository {
  static const _aiTimeout = Duration(seconds: 60);

  /// POST /api/ai/recipes — AI tạo món, backend lưu vào DB (chờ chuyên gia duyệt).
  ///
  /// Response chỉ có chuỗi `recipesJson` (không kèm id). Để mẹ lưu được món,
  /// tải lại `pendingCount` món mới nhất trong `/api/recipes/my` (đã có id);
  /// nếu không lấy được thì trả bản từ `recipesJson`.
  static Future<List<MomRecipe>> generate(RecipePreferences prefs) async {
    final response = await ApiService.post(
      '/api/ai/recipes',
      data: {'query': prefs.toQuery()},
      timeout: _aiTimeout,
    );

    final body = Map<String, dynamic>.from(response.data as Map);
    if (body['success'] != true || body['data'] is! Map) {
      throw Exception(body['message'] ?? 'AI chưa tạo được món, mẹ thử lại nhé.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);

    final pending = (data['pendingCount'] as num?)?.toInt() ?? 0;
    if (pending > 0) {
      try {
        final saved = await myRecipes(limit: pending);
        if (saved.length == pending) return saved;
      } catch (_) {
        // Rơi xuống dùng recipesJson
      }
    }

    final decoded = jsonDecode(data['recipesJson']?.toString() ?? '[]');
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => MomRecipe.fromAi(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// GET /api/recipes/my?category=Mom — chỉ món cho mẹ (không lẫn món ăn dặm của bé).
  static Future<List<MomRecipe>> myRecipes({bool? isSaved, int page = 1, int limit = 20}) async {
    final response = await ApiService.get(
      '/api/recipes/my',
      queryParameters: {
        'category': 'Mom',
        'isSaved': ?isSaved,
        'page': page,
        'limit': limit,
      },
    );
    final body = Map<String, dynamic>.from(response.data as Map);
    final data = body['data'] is Map ? Map<String, dynamic>.from(body['data'] as Map) : {};
    final list = data['recipes'] as List? ?? [];
    return list
        .whereType<Map>()
        .map((e) => MomRecipe.fromDb(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// PATCH /api/recipes/{id}/save — bật/tắt lưu, trả trạng thái mới.
  static Future<bool> toggleSave(int recipeId) async {
    final response = await ApiService.patch('/api/recipes/$recipeId/save');
    final body = Map<String, dynamic>.from(response.data as Map);
    final data = body['data'];
    return data is Map && data['isSaved'] == true;
  }

  /// GET /api/recipes/profiles/current
  static Future<NutritionProfile> currentProfile() async {
    final response = await ApiService.get('/api/recipes/profiles/current');
    final body = Map<String, dynamic>.from(response.data as Map);
    return NutritionProfile.fromJson(Map<String, dynamic>.from(body['data'] as Map? ?? {}));
  }
}
