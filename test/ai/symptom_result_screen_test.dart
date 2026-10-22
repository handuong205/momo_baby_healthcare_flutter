import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:momo_baby_healthcare_flutter/models/symptom/symptom_analysis.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/symptom_result_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('Màn 11: mức độ Cao hiện cảnh báo đi khám, bác sĩ và miễn trừ', (tester) async {
    final analysis = SymptomAnalysis.fromJson({
      'id': 1,
      'textDescription': 'Đau đầu, hoa mắt',
      'possibleConditionsJson': jsonEncode({
        'possibleConditions': [
          {'name': 'Tiền sản giật', 'probability': 'Có thể', 'description': 'Cần đo huyết áp.'},
        ],
        'urgencyReason': 'Cần khám sớm.',
        'recommendations': ['Đo huyết áp'],
        'specialistType': 'Sản khoa',
      }),
      'urgencyLevel': 'High',
      'shouldSeeDoctor': true,
      'severityScore': 72,
    });

    await tester.pumpWidget(_wrap(SymptomResultScreen(analysis: analysis)));

    expect(find.text('Cao'), findsOneWidget);
    expect(find.text('Điểm đánh giá của AI: 72/100'), findsOneWidget);
    expect(find.text('Mẹ nên đi khám sớm'), findsOneWidget);
    expect(find.text('Nên gặp bác sĩ chuyên khoa: Sản khoa.'), findsOneWidget);
    expect(find.text('Tiền sản giật'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Miễn trừ trách nhiệm'), 300);
    expect(find.text('BS. Vũ Thị Thu'), findsOneWidget);
    expect(find.text('Miễn trừ trách nhiệm'), findsOneWidget);
  });

  testWidgets('Màn 11: AI lỗi thì báo rõ, không hiện mức độ giả', (tester) async {
    final analysis = SymptomAnalysis.fromJson({
      'id': 2,
      'textDescription': 'Mệt mỏi',
      'possibleConditionsJson': '',
      'urgencyLevel': null,
    });

    await tester.pumpWidget(_wrap(SymptomResultScreen(analysis: analysis)));

    expect(find.text('AI chưa phân tích được'), findsOneWidget);
    expect(find.text('Mức độ cần chú ý'), findsNothing);
    expect(find.text('Mẹ nên đi khám sớm'), findsNothing);
  });
}
