import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/widget/epds_question_card.dart';

void main() {
  testWidgets('thẻ câu hỏi EPDS hiện 4 lựa chọn và báo câu đã chọn', (
    tester,
  ) async {
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EpdsQuestionCard(
              index: 0,
              total: epdsQuestions.length,
              question: epdsQuestions.first,
              selected: null,
              onSelected: (score) => picked = score,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Câu 1/10'), findsOneWidget);
    for (final option in epdsQuestions.first.options) {
      expect(find.text(option), findsOneWidget);
    }

    await tester.tap(find.text(epdsQuestions.first.options[2]));
    expect(picked, 2);
  });
}
