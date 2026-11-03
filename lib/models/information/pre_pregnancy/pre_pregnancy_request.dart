
class PrePregnancyRequest {
  final DateTime periodStartDate;
  final int cycleLength;
  final List<String> symptoms;

  const PrePregnancyRequest({
    required this.periodStartDate,
    required this.cycleLength,
    required this.symptoms,
  });

  Map<String, dynamic> toJson() {
    return {
      // Giữ nguyên ngày lịch mẹ chọn: `toUtc()` sẽ lùi về hôm trước ở múi giờ +7
      // và backend tính ngày rụng trứng trực tiếp từ giá trị này.
      'periodStartDate': DateTime.utc(
        periodStartDate.year,
        periodStartDate.month,
        periodStartDate.day,
      ).toIso8601String(),
      'cycleLength': cycleLength,
      'symptoms': symptoms,
    };
  }
}
