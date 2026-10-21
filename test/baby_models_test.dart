import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/models/baby/baby_models.dart';

void main() {
  test('parses baby profile and growth records from API JSON', () {
    final profile = BabyProfile.fromJson({
      'id': 3,
      'userId': 'user-1',
      'babyName': 'Bơ',
      'dateOfBirth': '2025-01-10T00:00:00Z',
      'gender': 0,
      'currentWeightKg': 7.8,
      'currentHeightCm': 68.5,
      'ageMonths': 12,
      'allergies': ['Trứng'],
      'growthRecords': [
        {
          'id': 10,
          'recordedAt': '2026-01-10T00:00:00Z',
          'weightKg': 7.8,
          'heightCm': 68.5,
        },
      ],
    });

    expect(profile.isBoy, isTrue);
    expect(profile.babyName, 'Bơ');
    expect(profile.growthRecords.single.weightKg, 7.8);
  });
}
