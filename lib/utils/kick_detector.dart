import 'dart:math' as math;

/// Đếm cử động thai từ cảm biến gia tốc: điện thoại đặt trên bụng mẹ, mỗi lần
/// bé đạp làm gia tốc lệch khỏi trọng lực nền.
///
/// Tách khỏi UI để test được mà không cần máy thật.
class KickDetector {
  /// Độ lệch gia tốc (m/s²) đủ để tính là một cử động.
  final double threshold;

  /// Khoảng nghỉ tối thiểu giữa 2 lần đếm, tránh 1 cú đạp bị đếm nhiều lần.
  final Duration refractory;

  /// Trọng lực nền trôi chậm (trung bình trượt).
  double _baseline = 0;
  bool _started = false;
  DateTime? _lastKick;

  KickDetector({
    this.threshold = 1.6,
    this.refractory = const Duration(milliseconds: 700),
  });

  /// Nạp một mẫu gia tốc; trả `true` nếu mẫu này được tính là một cử động.
  bool addSample(double x, double y, double z, DateTime now) {
    final magnitude = math.sqrt(x * x + y * y + z * z);
    if (!_started) {
      _baseline = magnitude;
      _started = true;
      return false;
    }

    final delta = (magnitude - _baseline).abs();
    _baseline += (magnitude - _baseline) * 0.05;

    if (delta < threshold) return false;
    if (_lastKick != null && now.difference(_lastKick!) < refractory) return false;

    _lastKick = now;
    return true;
  }

  void reset() {
    _started = false;
    _lastKick = null;
  }
}
