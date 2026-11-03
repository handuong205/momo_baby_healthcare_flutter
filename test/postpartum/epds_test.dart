import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';

void main() {
  group('EpdsOutcome', () {
    test('tổng điểm là tổng 10 câu', () {
      final outcome = EpdsOutcome.fromAnswers([0, 1, 0, 2, 1, 0, 1, 0, 2, 0]);
      expect(outcome.score, 7);
      expect(outcome.level, EpdsLevel.low);
      expect(outcome.selfHarmRisk, isFalse);
    });

    test('10-12 điểm là mức cần theo dõi', () {
      expect(
        EpdsOutcome.fromAnswers([2, 1, 1, 1, 1, 1, 1, 1, 1, 0]).level,
        EpdsLevel.moderate,
      );
      expect(
        EpdsOutcome.fromAnswers([2, 2, 2, 1, 1, 1, 1, 1, 1, 0]).score,
        12,
      );
    });

    test('từ 13 điểm là mức cao', () {
      final outcome = EpdsOutcome.fromAnswers([2, 2, 2, 2, 2, 1, 1, 1, 0, 0]);
      expect(outcome.score, 13);
      expect(outcome.level, EpdsLevel.high);
    });

    test('câu 10 khác 0 luôn là mức cao dù tổng điểm thấp', () {
      final outcome = EpdsOutcome.fromAnswers([0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);
      expect(outcome.score, 1);
      expect(outcome.selfHarmRisk, isTrue);
      expect(outcome.level, EpdsLevel.high);
    });

    test('mỗi câu có 4 lựa chọn, khớp thang điểm 0-3', () {
      expect(epdsQuestions, hasLength(10));
      for (final question in epdsQuestions) {
        expect(question.options, hasLength(4));
      }
    });
  });
}
