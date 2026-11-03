import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/utils/who_data.dart';

void main() {
  test('interpolates WHO reference at one month', () {
    final reference = whoAt(whoTable(GrowthMetric.weight, true), 1);
    expect(reference, isNotNull);
    expect(reference!.p50, closeTo(4.45, 0.0001));
  });

  test('classifies values using WHO percentile boundaries', () {
    expect(
      classifyGrowth(GrowthMetric.weight, true, 0, 2.4),
      'Nhẹ cân so với chuẩn',
    );
    expect(
      classifyGrowth(GrowthMetric.weight, true, 0, 3.3),
      'Trong mức chuẩn',
    );
  });
}
