import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:momo_baby_healthcare_flutter/models/recipe/mom_recipe.dart';
import 'package:momo_baby_healthcare_flutter/models/symptom/symptom_analysis.dart';
import 'package:momo_baby_healthcare_flutter/repositories/recipe/recipe_repository.dart';

/// Dữ liệu mẫu theo đúng shape backend trả về (SymptomLog, Recipe, recipesJson).
void main() {
  group('SymptomAnalysis.fromJson', () {
    test('đọc kết quả AI nằm trong chuỗi possibleConditionsJson', () {
      final ai = {
        'possibleConditions': [
          {'name': 'Tiền sản giật', 'probability': 'Có thể', 'description': 'Huyết áp cao kèm phù.'},
        ],
        'lifestyleConnection': 'Thiếu ngủ có thể làm đau đầu nặng hơn.',
        'urgencyLevel': 'Cao',
        'urgencyReason': 'Đau đầu kèm hoa mắt khi mang thai cần khám sớm.',
        'recommendations': ['Đo huyết áp', 'Nghỉ ngơi'],
        'dietarySuggestions': ['Giảm muối'],
        'disclaimer': 'Chỉ để tham khảo.',
        'shouldSeeDoctor': true,
        'specialistType': 'Sản khoa',
        'severityScore': 72,
      };
      final log = {
        'id': 12,
        'textDescription': 'Đau đầu, hoa mắt, phù chân',
        'imageUrl': null,
        'possibleConditionsJson': jsonEncode(ai),
        'urgencyLevel': 'High',
        'shouldSeeDoctor': true,
        'severityScore': 72,
        'createdAt': '2026-10-21T03:15:00Z',
      };

      final a = SymptomAnalysis.fromJson(log);

      expect(a.id, 12);
      expect(a.aiAvailable, isTrue);
      expect(a.urgencyLevel, UrgencyLevel.high);
      expect(a.severityScore, 72);
      expect(a.isUrgent, isTrue);
      expect(a.specialistType, 'Sản khoa');
      expect(a.possibleConditions.single.name, 'Tiền sản giật');
      expect(a.recommendations, ['Đo huyết áp', 'Nghỉ ngơi']);
      expect(a.dietarySuggestions, ['Giảm muối']);
      expect(a.createdAt, isNotNull);
    });

    test('AI lỗi: chuỗi rỗng + urgencyLevel null -> không hiện kết quả giả', () {
      final a = SymptomAnalysis.fromJson({
        'id': 3,
        'textDescription': 'Mệt mỏi cả ngày',
        'possibleConditionsJson': '',
        'urgencyLevel': null,
        'shouldSeeDoctor': false,
        'severityScore': 0,
      });

      expect(a.aiAvailable, isFalse);
      expect(a.urgencyLevel, UrgencyLevel.unknown);
      expect(a.isUrgent, isFalse);
      expect(a.possibleConditions, isEmpty);
    });

    test('AI trả thẳng mảng điều kiện thay vì object', () {
      final a = SymptomAnalysis.fromJson({
        'id': 4,
        'textDescription': 'Ngứa da',
        'possibleConditionsJson': jsonEncode([
          {'name': 'Dị ứng da', 'probability': 'Cao', 'description': ''},
        ]),
        'urgencyLevel': 'Low',
      });

      expect(a.aiAvailable, isTrue);
      expect(a.urgencyLevel, UrgencyLevel.low);
      expect(a.possibleConditions.single.name, 'Dị ứng da');
    });
  });

  group('MomRecipe', () {
    test('fromDb đọc cột phẳng + chuỗi JSON nguyên liệu/các bước', () {
      final r = MomRecipe.fromDb({
        'id': 7,
        'title': 'Cháo cá hồi bí đỏ',
        'calories': 320,
        'protein': 18.5,
        'carbs': 40,
        'fat': 9,
        'prepTimeMinutes': 25,
        'difficulty': 'Medium',
        'ingredientsJson': jsonEncode(['Cá hồi 100g', 'Bí đỏ 80g']),
        'stepsJson': jsonEncode(['Nấu cháo', 'Cho cá vào']),
        'isSaved': true,
        'status': 'Approved',
      });

      expect(r.id, 7);
      expect(r.difficulty, 'Trung bình');
      expect(r.ingredients, hasLength(2));
      expect(r.steps.first, 'Nấu cháo');
      expect(r.isSaved, isTrue);
      expect(r.status, RecipeReviewStatus.approved);
    });

    test('fromAi đọc chỉ số dạng chuỗi có đơn vị', () {
      final r = MomRecipe.fromAi({
        'recipe': 'Gà hấp lá chanh',
        'calories': '250 kcal',
        'protein': '30g',
        'prepTime': '20 phút',
        'difficulty': 'Dễ',
        'ingredients': ['Ức gà', 'Lá chanh'],
        'steps': ['Ướp gà', 'Hấp 15 phút'],
      });

      expect(r.id, isNull);
      expect(r.title, 'Gà hấp lá chanh');
      expect(r.calories, 250);
      expect(r.protein, 30);
      expect(r.prepTimeMinutes, 20);
      expect(r.status, RecipeReviewStatus.pending);
    });

    test('copyWith chỉ đổi trạng thái lưu', () {
      const r = MomRecipe(id: 1, title: 'A');
      expect(r.copyWith(isSaved: true).isSaved, isTrue);
      expect(r.copyWith(isSaved: true).title, 'A');
    });
  });

  test('RecipePreferences.toQuery khớp định dạng của bản web', () {
    const prefs = RecipePreferences(dietType: 'Ít muối', maxCookTime: 45, availableIngredients: 'ức gà');
    expect(
      prefs.toQuery(),
      'Chế độ ăn: Ít muối, Dị ứng: Không, Thời gian nấu tối đa: 45 phút, Nguyên liệu có sẵn: ức gà',
    );
  });
}
