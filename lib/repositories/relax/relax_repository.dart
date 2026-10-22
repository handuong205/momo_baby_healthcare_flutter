import 'package:momo_baby_healthcare_flutter/exceptions/api_unwrap.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

/// Mức căng thẳng theo enum `StressLevel` của backend.
enum StressLevel {
  low('Low', 'Thư thái', '😌'),
  moderate('Moderate', 'Hơi căng thẳng', '😐'),
  high('High', 'Rất căng thẳng', '😣');

  const StressLevel(this.apiValue, this.label, this.emoji);

  final String apiValue;
  final String label;
  final String emoji;

  static StressLevel? fromApi(Object? value) {
    final v = value?.toString().toLowerCase();
    for (final level in values) {
      if (level.apiValue.toLowerCase() == v) return level;
    }
    return null;
  }
}

/// Nhật ký lối sống hôm nay từ `GET /api/lifestyle/today`.
class LifestyleToday {
  const LifestyleToday({
    this.selfCareHours = 0,
    this.sleepHours = 0,
    this.physicalHours = 0,
    this.socialHours = 0,
    this.waterLiters = 0,
    this.stressLevel,
    this.healthScore,
  });

  final double selfCareHours;
  final double sleepHours;
  final double physicalHours;
  final double socialHours;
  final double waterLiters;

  /// `null` khi hôm nay mẹ chưa ghi nhật ký nào.
  final StressLevel? stressLevel;
  final int? healthScore;

  int get selfCareMinutes => (selfCareHours * 60).round();

  static double _num(Object? v) => v is num ? v.toDouble() : 0;

  factory LifestyleToday.fromJson(Map<String, dynamic> json) {
    // Backend trả `{}` khi chưa có nhật ký hôm nay.
    if (json['id'] == null) return const LifestyleToday();
    return LifestyleToday(
      selfCareHours: _num(json['selfCareHours']),
      sleepHours: _num(json['sleepHours']),
      physicalHours: _num(json['physicalHours']),
      socialHours: _num(json['socialHours']),
      waterLiters: _num(json['waterLiters']),
      stressLevel: StressLevel.fromApi(json['stressLevel']),
      healthScore: (json['healthScore'] as num?)?.toInt(),
    );
  }
}

/// Thư giãn ghi vào nhật ký lối sống của backend (`/api/lifestyle`): mức căng
/// thẳng mẹ tự chọn và thời gian thư giãn được cộng vào "chăm sóc bản thân".
///
/// `POST /api/lifestyle/entry` ghi đè cả ngày, nên luôn đọc bản hôm nay rồi
/// chỉ đổi trường cần đổi để không xóa giấc ngủ, nước uống… đã ghi ở màn khác.
class RelaxRepository {
  RelaxRepository._();

  static Future<LifestyleToday> today() async {
    final response = await ApiService.get('/api/lifestyle/today');
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return data == null
        ? const LifestyleToday()
        : LifestyleToday.fromJson(data);
  }

  static Future<LifestyleToday> setStress(StressLevel level) =>
      _serial(() async {
        final current = await today();
        return _save(current, stressLevel: level);
      });

  static Future<LifestyleToday> addSelfCare(Duration duration) =>
      _serial(() async {
        final current = await today();
        return _save(
          current,
          selfCareHours: current.selfCareHours + duration.inSeconds / 3600,
        );
      });

  /// Đọc-rồi-ghi phải chạy lần lượt, kẻo hai lần ghi cùng lúc đè mất nhau.
  static Future<void> _last = Future.value();

  static Future<T> _serial<T>(Future<T> Function() task) {
    final result = _last.then((_) => task());
    _last = result.then((_) {}, onError: (_) {});
    return result;
  }

  static Future<LifestyleToday> _save(
    LifestyleToday current, {
    StressLevel? stressLevel,
    double? selfCareHours,
  }) async {
    final response = await ApiService.post(
      '/api/lifestyle/entry',
      data: {
        'selfCareHours': double.parse(
          (selfCareHours ?? current.selfCareHours).toStringAsFixed(2),
        ),
        'sleepHours': current.sleepHours,
        'physicalHours': current.physicalHours,
        'socialHours': current.socialHours,
        'waterLiters': current.waterLiters,
        'stressLevel':
            (stressLevel ?? current.stressLevel ?? StressLevel.low).apiValue,
      },
    );
    final data = unwrapApiData<Map<String, dynamic>>(response.data);
    return data == null ? current : LifestyleToday.fromJson(data);
  }
}
