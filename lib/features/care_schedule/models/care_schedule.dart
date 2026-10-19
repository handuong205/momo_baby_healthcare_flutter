import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/mom_ui.dart';

/// Loại việc chăm sóc. Backend chỉ có bảng lịch nhắc `/api/medications`
/// (tên + liều + giờ + khoảng ngày), nên với việc không phải thuốc, nhãn loại
/// được lưu ở trường `dosage` để app Mobile vẫn hiển thị dễ hiểu.
enum CareCategory {
  medicine('Thuốc / vitamin', LucideIcons.pill, MomTheme.purple),
  feeding('Cho bé bú / ăn', LucideIcons.milk, MomTheme.amberDark),
  sleep('Giấc ngủ', LucideIcons.moon, MomTheme.blue),
  bath('Tắm bé / vệ sinh', LucideIcons.bath, MomTheme.sageDark),
  vaccine('Tiêm chủng', LucideIcons.syringe, MomTheme.danger),
  checkup('Khám thai / tái khám', LucideIcons.stethoscope, MomTheme.roseDeep),
  other('Việc khác', LucideIcons.heart, MomTheme.muted);

  const CareCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Lịch tạo từ màn "Lịch uống thuốc" có `dosage` là liều thuốc → [medicine].
  static CareCategory fromDosage(String dosage) => CareCategory.values
      .firstWhere((c) => c.label == dosage, orElse: () => medicine);
}

enum AdherenceStatus { taken, skipped }

String _pad(int n) => n.toString().padLeft(2, '0');

/// Ngày mẹ chọn → ISO 00:00 UTC (giống `toUtcDateIso` của Mobile).
String toUtcDateIso(DateTime date) =>
    '${date.year}-${_pad(date.month)}-${_pad(date.day)}T00:00:00.000Z';

/// Ngày backend trả về → DateTime địa phương đúng ngày lịch đó.
DateTime? fromUtcDateIso(Object? value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  if (parsed == null) return null;
  final utc = parsed.toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}

DateTime startOfToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String formatDate(DateTime? d) =>
    d == null ? '' : '${_pad(d.day)}/${_pad(d.month)}/${d.year}';

String formatTime(TimeOfDay t) => '${_pad(t.hour)}:${_pad(t.minute)}';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Một lịch nhắc từ `GET /api/medications`.
class CareSchedule {
  const CareSchedule({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.logs = const [],
  });

  final int id;
  final String name;
  final String dosage;

  /// Giờ nhắc "HH:mm".
  final List<String> times;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final List<({DateTime date, AdherenceStatus status})> logs;

  CareCategory get category => CareCategory.fromDosage(dosage);

  /// Dòng phụ: liều thuốc (với thuốc) hoặc chỉ giờ (với việc khác).
  String get meta => category == CareCategory.medicine
      ? '$dosage · ${times.join(', ')}'
      : times.join(', ');

  bool get isOneDay => endDate.difference(startDate).inDays <= 1;

  String get dateRange => isOneDay
      ? 'Ngày ${formatDate(startDate)}'
      : '${formatDate(startDate)} → ${formatDate(endDate)}';

  bool activeOn(DateTime day) =>
      !day.isBefore(startDate) && !day.isAfter(endDate);

  /// Trạng thái hôm nay (backend ghi theo ngày, không theo từng giờ).
  AdherenceStatus? statusOn(DateTime day) {
    for (final log in logs) {
      if (_sameDay(log.date, day)) return log.status;
    }
    return null;
  }

  factory CareSchedule.fromJson(Map<String, dynamic> json) {
    final start = fromUtcDateIso(json['startDate']) ?? startOfToday();
    return CareSchedule(
      id: (json['id'] as num).toInt(),
      name: json['medName']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      times: [...?(json['times'] as List?)?.map((e) => e.toString())]..sort(),
      startDate: start,
      endDate: fromUtcDateIso(json['endDate']) ?? start,
      notes: (json['notes']?.toString().trim().isEmpty ?? true)
          ? null
          : json['notes'].toString(),
      logs: [
        for (final log
            in (json['adherenceLogs'] as List? ?? const [])
                .whereType<Map<String, dynamic>>())
          if (fromUtcDateIso(log['date']) case final date?)
            (
              date: date,
              status: log['status']?.toString().toLowerCase() == 'skipped'
                  ? AdherenceStatus.skipped
                  : AdherenceStatus.taken,
            ),
      ],
    );
  }
}
