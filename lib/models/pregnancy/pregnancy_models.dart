/// Model cho nhóm `GET /api/pregnancy/*`.
library;

DateTime? _dateOnly(Object? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

/// `GET /api/pregnancy/this-week`.
class PregnancyWeekInfo {
  final int week;
  final String? babySize;
  final String? development;
  final String? momTips;

  const PregnancyWeekInfo({
    required this.week,
    this.babySize,
    this.development,
    this.momTips,
  });

  factory PregnancyWeekInfo.fromJson(Map<String, dynamic> json) {
    String? text(Object? v) => v?.toString();
    return PregnancyWeekInfo(
      week: (json['week'] as num?)?.toInt() ?? 0,
      babySize: text(json['babySize']),
      development: text(json['development']),
      momTips: text(json['momTips']),
    );
  }
}

/// `POST /api/pregnancy/setup`.
class PregnancySetupResult {
  final int pregnancyWeek;
  final int trimester;
  final DateTime? dueDate;
  final String milestone;

  const PregnancySetupResult({
    this.pregnancyWeek = 0,
    this.trimester = 1,
    this.dueDate,
    this.milestone = '',
  });

  factory PregnancySetupResult.fromJson(Map<String, dynamic> json) {
    return PregnancySetupResult(
      pregnancyWeek: (json['pregnancyWeek'] as num?)?.toInt() ?? 0,
      trimester: (json['trimester'] as num?)?.toInt() ?? 1,
      dueDate: _dateOnly(json['dueDate']),
      milestone: json['milestone']?.toString() ?? '',
    );
  }
}
