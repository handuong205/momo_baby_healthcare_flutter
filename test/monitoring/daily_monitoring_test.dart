import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/models/information/pre_pregnancy/pre_pregnancy_request.dart';
import 'package:momo_baby_healthcare_flutter/models/monitoring/daily_monitoring.dart';
import 'package:momo_baby_healthcare_flutter/models/notification/notification_alert.dart';

void main() {
  test('DailyMonitoringLog đọc đúng JSON của backend', () {
    final log = DailyMonitoringLog.fromJson({
      'date': '2026-11-03T00:00:00Z',
      'sleepHours': 7.5,
      'sleepQuality': 4,
      'waterLiters': 1.5,
      'hadBreakfast': true,
      'hadLunch': false,
      'moodScore': 4,
      'bloodPressureHigh': 110,
      'bloodPressureLow': 70,
      'weight': 55,
      'symptomSeverity': 1,
    });

    expect(log.date?.day, 3);
    expect(log.sleepHours, 7.5);
    expect(log.hadBreakfast, isTrue);
    expect(log.hadDinner, isFalse);
    expect(log.bloodPressureHigh, 110);
    expect(log.weight, 55);
    expect(log.bloodSugar, isNull);
  });

  test('MonitoringInsights đọc đúng JSON của backend', () {
    final insights = MonitoringInsights.fromJson({
      'averageSleepHours': 7.5,
      'averageWaterLiters': 1.5,
      'averageMoodScore': 4,
      'mealConsistencyPercent': 33.3,
      'totalDays': 1,
    });

    expect(insights.averageMoodScore, 4);
    expect(insights.mealConsistencyPercent, 33.3);
    expect(insights.totalDays, 1);
  });

  test('NotificationAlert đổi trạng thái khi đã xem', () {
    final alert = NotificationAlert.fromJson({
      'id': 1,
      'type': 'Symptom',
      'severity': 'Medium',
      'message': 'Test',
      'status': 'Pending',
      'createdAt': '2026-11-03T03:33:17.61487Z',
    });

    expect(alert.isResolved, isFalse);
    expect(alert.resolved().isResolved, isTrue);
    expect(alert.resolved().message, 'Test');
  });

  test('PrePregnancyRequest giữ đúng ngày lịch mẹ chọn', () {
    final json = PrePregnancyRequest(
      periodStartDate: DateTime(2026, 10, 20),
      cycleLength: 30,
      symptoms: const [],
    ).toJson();

    expect(json['periodStartDate'], '2026-10-20T00:00:00.000Z');
  });
}
