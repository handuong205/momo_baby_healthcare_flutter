
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
      'periodStartDate': periodStartDate.toUtc().toIso8601String(),
      'cycleLength': cycleLength,
      'symptoms': symptoms,
    };
  }
}
