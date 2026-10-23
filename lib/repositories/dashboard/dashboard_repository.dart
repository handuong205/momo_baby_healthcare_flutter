import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

/// Backend lưu lượng nước theo lít (2,5 lít = 100% mục tiêu), app hiển thị
/// theo ly 250 ml. Giống `utils/monitoring.ts` bên RN.
const double litersPerCup = 0.25;
const int dailyCupGoal = 10;

int cupsFromLiters(num? liters) {
  if (liters == null || liters <= 0) return 0;
  return (liters / litersPerCup).round();
}

class MoodOption {
  final int score;
  final String emoji;
  final String label;

  /// Ảnh thay cho emoji (nền trong suốt); `null` thì dùng [emoji].
  final String? imageAsset;

  const MoodOption(this.score, this.emoji, this.label, {this.imageAsset});
}

const String _emojiDir = 'assets/images/emoji';

/// Thang 1-5 giống web (MoodForm). Ảnh dùng bản `_transparent` (đã bỏ nền
/// trắng và cắt lề); emoji chữ chỉ dùng khi ảnh lỗi.
const List<MoodOption> moodOptions = [
  MoodOption(
    1,
    '😣',
    'Rất mệt',
    imageAsset: '$_emojiDir/very_tired_transparent.png',
  ),
  MoodOption(
    2,
    '😕',
    'Không vui',
    imageAsset: '$_emojiDir/unhapi_transparent.png',
  ),
  MoodOption(
    3,
    '🙂',
    'Bình thường',
    imageAsset: '$_emojiDir/normal_transparent.png',
  ),
  MoodOption(4, '😄', 'Vui vẻ', imageAsset: '$_emojiDir/hapi_transparent.png'),
  MoodOption(
    5,
    '🤩',
    'Tuyệt vời',
    imageAsset: '$_emojiDir/awsome_transparent.png',
  ),
];

/// Giai đoạn của mẹ: 0 chuẩn bị, 1 mang thai, 2 sau sinh.
/// Backend trả enum dạng chuỗi (PrePregnancy/Pregnant/Postpartum).
int stageIndexOf(Object? stage) {
  if (stage == 1 || stage == 'Pregnant') return 1;
  if (stage == 2 || stage == 'Postpartum') return 2;
  return 0;
}

/// Phần hồ sơ mẹ mà trang chủ cần (`GET /api/user-profile`).
class DashboardProfile {
  final int stage;
  final int? pregnancyWeek;
  final bool needsSetup;

  const DashboardProfile({
    required this.stage,
    this.pregnancyWeek,
    this.needsSetup = false,
  });

  factory DashboardProfile.fromJson(Map<String, dynamic> json) {
    bool isEmpty(Object? v) => v == null || v.toString().isEmpty;
    return DashboardProfile(
      stage: stageIndexOf(json['stage']),
      pregnancyWeek: (json['pregnancyWeek'] as num?)?.toInt(),
      needsSetup:
          isEmpty(json['lastPeriodDate']) &&
          isEmpty(json['deliveryDate']) &&
          isEmpty(json['height']) &&
          isEmpty(json['weight']),
    );
  }
}

/// Nhật ký theo dõi hôm nay (`GET /api/daily-monitoring/today`).
class TodayMonitoring {
  final int waterCups;
  final int? moodScore;
  final num? sleepHours;

  const TodayMonitoring({this.waterCups = 0, this.moodScore, this.sleepHours});

  factory TodayMonitoring.fromJson(Map<String, dynamic>? log) {
    return TodayMonitoring(
      waterCups: cupsFromLiters(log?['waterLiters'] as num?),
      moodScore: (log?['moodScore'] as num?)?.toInt(),
      sleepHours: log?['sleepHours'] as num?,
    );
  }
}

/// Thông tin tuần thai (`GET /api/pregnancy/this-week`).
class PregnancyWeekInfo {
  final int week;
  final String? babySize;
  final String? development;

  const PregnancyWeekInfo({
    required this.week,
    this.babySize,
    this.development,
  });

  factory PregnancyWeekInfo.fromJson(Map<String, dynamic> json) {
    return PregnancyWeekInfo(
      week: (json['week'] as num?)?.toInt() ?? 0,
      babySize: json['babySize'] as String?,
      development: json['development'] as String?,
    );
  }
}

/// Các API mà màn Tổng quan dùng, theo `profileService` và
/// `featureService` bên RN.
class DashboardRepository {
  static Future<DashboardProfile?> getProfile() async {
    final response = await ApiService.get('/api/user-profile');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return data == null ? null : DashboardProfile.fromJson(data);
  }

  static Future<TodayMonitoring> getTodayMonitoring() async {
    final response = await ApiService.get('/api/daily-monitoring/today');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    // `data` có dạng { data: log | null, hasSubmittedToday }.
    final log = data?['data'];
    return TodayMonitoring.fromJson(log is Map<String, dynamic> ? log : null);
  }

  /// Backend gộp theo ngày: chỉ ghi đè các trường được gửi lên.
  static Future<void> saveDailyMonitoring(Map<String, dynamic> payload) async {
    final response = await ApiService.post(
      '/api/daily-monitoring',
      data: payload,
    );
    unwrapApiData<Object>(response.data);
  }

  /// Số thông báo chưa xử lý (status khác Resolved).
  static Future<int> getPendingAlertCount() async {
    final response = await ApiService.get('/api/alerts');
    final data = unwrapApiData<List<dynamic>>(response.data) ?? const [];
    return data.whereType<Map>().where((a) => a['status'] != 'Resolved').length;
  }

  static Future<PregnancyWeekInfo?> getPregnancyThisWeek() async {
    final response = await ApiService.get('/api/pregnancy/this-week');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return data == null ? null : PregnancyWeekInfo.fromJson(data);
  }
}
