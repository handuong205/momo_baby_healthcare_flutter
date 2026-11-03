/// Nhật ký một ngày (`DailyMonitoringLog` của backend).
class DailyMonitoringLog {
  final DateTime? date;
  final double? sleepHours;
  final int? sleepQuality;
  final double? waterLiters;
  final bool hadBreakfast;
  final bool hadLunch;
  final bool hadDinner;
  final int? moodScore;
  final String? moodNote;
  final double? bloodSugar;
  final int? bloodPressureHigh;
  final int? bloodPressureLow;
  final double? weight;
  final int? symptomSeverity;
  final String? symptomNote;

  const DailyMonitoringLog({
    this.date,
    this.sleepHours,
    this.sleepQuality,
    this.waterLiters,
    this.hadBreakfast = false,
    this.hadLunch = false,
    this.hadDinner = false,
    this.moodScore,
    this.moodNote,
    this.bloodSugar,
    this.bloodPressureHigh,
    this.bloodPressureLow,
    this.weight,
    this.symptomSeverity,
    this.symptomNote,
  });

  factory DailyMonitoringLog.fromJson(Map<String, dynamic> json) {
    return DailyMonitoringLog(
      // Backend lưu theo ngày dạng `...T00:00:00Z`: giữ nguyên ngày lịch, không
      // đổi múi giờ.
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      sleepQuality: (json['sleepQuality'] as num?)?.toInt(),
      waterLiters: (json['waterLiters'] as num?)?.toDouble(),
      hadBreakfast: json['hadBreakfast'] == true,
      hadLunch: json['hadLunch'] == true,
      hadDinner: json['hadDinner'] == true,
      moodScore: (json['moodScore'] as num?)?.toInt(),
      moodNote: json['moodNote'] as String?,
      bloodSugar: (json['bloodSugar'] as num?)?.toDouble(),
      bloodPressureHigh: (json['bloodPressureHigh'] as num?)?.toInt(),
      bloodPressureLow: (json['bloodPressureLow'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      symptomSeverity: (json['symptomSeverity'] as num?)?.toInt(),
      symptomNote: json['symptomNote'] as String?,
    );
  }
}

/// Xu hướng N ngày (`GET /api/daily-monitoring/insights`).
class MonitoringInsights {
  final double averageSleepHours;
  final double averageWaterLiters;
  final double averageMoodScore;
  final double mealConsistencyPercent;
  final int totalDays;

  const MonitoringInsights({
    required this.averageSleepHours,
    required this.averageWaterLiters,
    required this.averageMoodScore,
    required this.mealConsistencyPercent,
    required this.totalDays,
  });

  factory MonitoringInsights.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return MonitoringInsights(
      averageSleepHours: number('averageSleepHours'),
      averageWaterLiters: number('averageWaterLiters'),
      averageMoodScore: number('averageMoodScore'),
      mealConsistencyPercent: number('mealConsistencyPercent'),
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
    );
  }
}
