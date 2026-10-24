/// Model cho `GET /api/fertility/calendar?month=yyyy-MM` và
/// `GET /api/fertility/ovulation-today`.
///
/// Backend trả ngày dạng ISO 00:00 UTC, nên chỉ giữ phần ngày để so sánh.
DateTime? dateOnly(Object? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

class FertilityCalendar {
  final List<DateTime> fertileWindowDays;
  final DateTime? ovulationDay;
  final DateTime? periodPrediction;

  const FertilityCalendar({
    this.fertileWindowDays = const [],
    this.ovulationDay,
    this.periodPrediction,
  });

  factory FertilityCalendar.fromJson(Map<String, dynamic> json) {
    final days = (json['fertileWindowDays'] as List<dynamic>? ?? const [])
        .map(dateOnly)
        .whereType<DateTime>()
        .toList();
    return FertilityCalendar(
      fertileWindowDays: days,
      ovulationDay: dateOnly(json['ovulationDay']),
      periodPrediction: dateOnly(json['periodPrediction']),
    );
  }

  static bool _sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  bool isOvulation(DateTime day) => _sameDay(ovulationDay, day);

  bool isPeriod(DateTime day) => _sameDay(periodPrediction, day);

  bool isFertile(DateTime day) => fertileWindowDays.any((d) => _sameDay(d, day));
}

/// `GET /api/fertility/ovulation-today`.
class OvulationStatus {
  final bool isInFertileWindow;
  final int daysUntilOvulation;
  final String recommendation;

  const OvulationStatus({
    this.isInFertileWindow = false,
    this.daysUntilOvulation = 0,
    this.recommendation = '',
  });

  factory OvulationStatus.fromJson(Map<String, dynamic> json) {
    return OvulationStatus(
      isInFertileWindow: json['isInFertileWindow'] == true,
      daysUntilOvulation: (json['daysUntilOvulation'] as num?)?.toInt() ?? 0,
      recommendation: json['recommendation']?.toString() ?? '',
    );
  }
}
