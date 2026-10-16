class MomProfile {
  const MomProfile({
    this.stage,
    this.pregnancyWeek,
    this.height,
    this.weight,
    this.lastPeriodDate,
    this.deliveryDate,
  });

  final Object? stage;
  final int? pregnancyWeek;
  final Object? height;
  final Object? weight;
  final String? lastPeriodDate;
  final String? deliveryDate;

  factory MomProfile.fromJson(Map<String, dynamic> json) => MomProfile(
    stage: json['stage'],
    pregnancyWeek: (json['pregnancyWeek'] as num?)?.toInt(),
    height: json['height'],
    weight: json['weight'],
    lastPeriodDate: json['lastPeriodDate'] as String?,
    deliveryDate: json['deliveryDate'] as String?,
  );
}

class TodayMonitoring {
  const TodayMonitoring({this.waterLiters, this.moodScore, this.sleepHours});

  final double? waterLiters;
  final int? moodScore;
  final double? sleepHours;

  factory TodayMonitoring.fromResponse(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) return const TodayMonitoring();
    return TodayMonitoring(
      waterLiters: (data['waterLiters'] as num?)?.toDouble(),
      moodScore: (data['moodScore'] as num?)?.toInt(),
      sleepHours: (data['sleepHours'] as num?)?.toDouble(),
    );
  }
}

class PregnancyWeekInfo {
  const PregnancyWeekInfo({this.week, this.babySize, this.development});

  final int? week;
  final String? babySize;
  final String? development;

  factory PregnancyWeekInfo.fromJson(Map<String, dynamic> json) =>
      PregnancyWeekInfo(
        week: (json['week'] as num?)?.toInt(),
        babySize: json['babySize'] as String?,
        development: json['development'] as String?,
      );
}

class MoodOption {
  const MoodOption(this.score, this.emoji, this.label);

  final int score;
  final String emoji;
  final String label;
}

const moodOptions = [
  MoodOption(1, '😣', 'Rất mệt'),
  MoodOption(2, '😕', 'Không vui'),
  MoodOption(3, '🙂', 'Bình thường'),
  MoodOption(4, '😄', 'Vui vẻ'),
  MoodOption(5, '🤩', 'Tuyệt vời'),
];
