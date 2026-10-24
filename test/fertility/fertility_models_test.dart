import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/models/fertility/fertility_models.dart';
import 'package:momo_baby_healthcare_flutter/utils/kick_detector.dart';

void main() {
  group('FertilityCalendar', () {
    final calendar = FertilityCalendar.fromJson({
      'fertileWindowDays': [
        '2026-10-10T00:00:00Z',
        '2026-10-11T00:00:00Z',
      ],
      'ovulationDay': '2026-10-11T00:00:00Z',
      'periodPrediction': '2026-10-29T00:00:00Z',
    });

    test('parse ngày theo đúng ngày lịch của backend', () {
      expect(calendar.ovulationDay, DateTime(2026, 10, 11));
      expect(calendar.fertileWindowDays, hasLength(2));
    });

    test('phân loại ngày rụng trứng / dễ thụ thai / kinh dự đoán', () {
      expect(calendar.isOvulation(DateTime(2026, 10, 11)), isTrue);
      expect(calendar.isOvulation(DateTime(2026, 10, 12)), isFalse);
      expect(calendar.isFertile(DateTime(2026, 10, 10)), isTrue);
      expect(calendar.isFertile(DateTime(2026, 10, 20)), isFalse);
      expect(calendar.isPeriod(DateTime(2026, 10, 29)), isTrue);
    });

    test('dữ liệu rỗng không làm vỡ lịch', () {
      final empty = FertilityCalendar.fromJson(const {});
      expect(empty.fertileWindowDays, isEmpty);
      expect(empty.isOvulation(DateTime(2026, 10, 11)), isFalse);
    });
  });

  group('KickDetector', () {
    final t0 = DateTime(2026, 10, 23, 9);

    test('giữ yên thì không đếm', () {
      final detector = KickDetector();
      var kicks = 0;
      for (var i = 0; i < 50; i++) {
        if (detector.addSample(0, 0, 9.81, t0.add(Duration(milliseconds: i * 100)))) {
          kicks++;
        }
      }
      expect(kicks, 0);
    });

    test('một cú đạp mạnh được đếm đúng một lần', () {
      final detector = KickDetector();
      detector.addSample(0, 0, 9.81, t0);
      expect(detector.addSample(0, 0, 15, t0.add(const Duration(milliseconds: 200))), isTrue);
      // Cùng cú đạp, trong khoảng nghỉ nên không đếm lại.
      expect(detector.addSample(0, 0, 15, t0.add(const Duration(milliseconds: 400))), isFalse);
    });

    test('sau khoảng nghỉ, cú đạp mới lại được đếm', () {
      final detector = KickDetector();
      detector.addSample(0, 0, 9.81, t0);
      expect(detector.addSample(0, 0, 15, t0), isTrue);
      expect(
        detector.addSample(0, 0, 9.81, t0.add(const Duration(milliseconds: 500))),
        isFalse,
      );
      expect(
        detector.addSample(0, 0, 15, t0.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
