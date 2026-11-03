
class PostpartumSetupResponse {
  final int daysPostpartum;
  final String recoveryPhase;
  final String initialRecommendations;
  final String message;

  const PostpartumSetupResponse({
    required this.daysPostpartum,
    required this.recoveryPhase,
    required this.initialRecommendations,
    this.message = '',
  });

  factory PostpartumSetupResponse.fromJson(
    Map<String, dynamic> json, {
    String message = '',
  }) {
    return PostpartumSetupResponse(
      daysPostpartum: (json['daysPostpartum'] as num?)?.toInt() ?? 0,
      recoveryPhase: json['recoveryPhase'] as String? ?? '',
      initialRecommendations: json['initialRecommendations'] as String? ?? '',
      message: message,
    );
  }
}
