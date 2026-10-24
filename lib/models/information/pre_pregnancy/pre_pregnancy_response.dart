class PrePregnancyResponse {
  final DateTime? ovulationDay;
  final DateTime? fertileWindowStart;
  final DateTime? fertileWindowEnd;
  final DateTime? periodPrediction;

  const PrePregnancyResponse({
    this.ovulationDay,
    this.fertileWindowStart,
    this.fertileWindowEnd,
    this.periodPrediction,
  });

  factory PrePregnancyResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString())?.toLocal();
    }

    return PrePregnancyResponse(
      ovulationDay: parseDate(json['ovulationDay']),
      fertileWindowStart: parseDate(json['fertileWindowStart']),
      fertileWindowEnd: parseDate(json['fertileWindowEnd']),
      periodPrediction: parseDate(json['periodPrediction']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ovulationDay': ovulationDay?.toUtc().toIso8601String(),
      'fertileWindowStart': fertileWindowStart?.toUtc().toIso8601String(),
      'fertileWindowEnd': fertileWindowEnd?.toUtc().toIso8601String(),
      'periodPrediction': periodPrediction?.toUtc().toIso8601String(),
    };
  }
}
