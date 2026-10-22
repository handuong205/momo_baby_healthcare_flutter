import 'dart:convert';

/// Mức độ khẩn cấp do AI đánh giá. Backend trả enum dạng chuỗi
/// ("Low" | "Medium" | "High" | "Critical") hoặc null khi AI lỗi.
enum UrgencyLevel { low, medium, high, critical, unknown }

UrgencyLevel _parseUrgency(Object? raw) {
  switch (raw?.toString().trim().toLowerCase()) {
    case 'low':
    case 'thấp':
    case '0':
      return UrgencyLevel.low;
    case 'medium':
    case 'trung bình':
    case '1':
      return UrgencyLevel.medium;
    case 'high':
    case 'cao':
    case '2':
      return UrgencyLevel.high;
    case 'critical':
    case 'khẩn cấp':
    case '3':
      return UrgencyLevel.critical;
    default:
      return UrgencyLevel.unknown;
  }
}

class PossibleCondition {
  final String name;
  final String probability;
  final String description;

  const PossibleCondition({
    required this.name,
    required this.probability,
    required this.description,
  });

  factory PossibleCondition.fromJson(Map<String, dynamic> json) {
    return PossibleCondition(
      name: json['name']?.toString() ?? '',
      probability: json['probability']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

/// Một lần phân tích triệu chứng (bản ghi `SymptomLog` của backend).
///
/// Chi tiết phân tích của Gemini nằm BÊN TRONG chuỗi JSON
/// `possibleConditionsJson`, không phải thuộc tính cấp ngoài.
/// Chuỗi rỗng = AI lỗi, khi đó [aiAvailable] = false và không hiện kết quả giả.
class SymptomAnalysis {
  final int id;
  final String textDescription;
  final String? imageUrl;
  final DateTime? createdAt;
  final bool aiAvailable;

  final UrgencyLevel urgencyLevel;
  final int severityScore;
  final bool shouldSeeDoctor;
  final String? urgencyReason;
  final String? specialistType;
  final String? lifestyleConnection;
  final String? disclaimer;
  final List<PossibleCondition> possibleConditions;
  final List<String> recommendations;
  final List<String> dietarySuggestions;

  const SymptomAnalysis({
    required this.id,
    required this.textDescription,
    this.imageUrl,
    this.createdAt,
    required this.aiAvailable,
    required this.urgencyLevel,
    required this.severityScore,
    required this.shouldSeeDoctor,
    this.urgencyReason,
    this.specialistType,
    this.lifestyleConnection,
    this.disclaimer,
    this.possibleConditions = const [],
    this.recommendations = const [],
    this.dietarySuggestions = const [],
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    final raw = json['possibleConditionsJson']?.toString() ?? '';
    Map<String, dynamic> ai = {};
    List<dynamic> conditions = [];

    if (raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          ai = Map<String, dynamic>.from(decoded);
          conditions = ai['possibleConditions'] as List? ?? [];
        } else if (decoded is List) {
          // AI đôi khi trả thẳng mảng điều kiện thay vì object bọc ngoài
          conditions = decoded;
        }
      } catch (_) {
        // JSON hỏng: coi như AI lỗi
      }
    }

    List<String> strings(Object? v) =>
        (v as List?)?.map((e) => e.toString()).where((e) => e.isNotEmpty).toList() ?? [];

    final imageUrl = json['imageUrl']?.toString();

    return SymptomAnalysis(
      id: (json['id'] as num?)?.toInt() ?? 0,
      textDescription: json['textDescription']?.toString() ?? '',
      imageUrl: (imageUrl == null || imageUrl.isEmpty) ? null : imageUrl,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
      aiAvailable: raw.trim().isNotEmpty && (ai.isNotEmpty || conditions.isNotEmpty),
      urgencyLevel: _parseUrgency(json['urgencyLevel'] ?? ai['urgencyLevel']),
      severityScore: (json['severityScore'] as num?)?.toInt() ??
          (ai['severityScore'] as num?)?.toInt() ??
          0,
      shouldSeeDoctor: (json['shouldSeeDoctor'] as bool?) ??
          (ai['shouldSeeDoctor'] as bool?) ??
          false,
      urgencyReason: ai['urgencyReason']?.toString(),
      specialistType: ai['specialistType']?.toString(),
      lifestyleConnection: ai['lifestyleConnection']?.toString(),
      disclaimer: ai['disclaimer']?.toString(),
      possibleConditions: conditions
          .whereType<Map>()
          .map((c) => PossibleCondition.fromJson(Map<String, dynamic>.from(c)))
          .toList(),
      recommendations: strings(ai['recommendations']),
      dietarySuggestions: strings(ai['dietarySuggestions']),
    );
  }

  /// Cần khuyên đi khám sớm: AI bảo nên gặp bác sĩ hoặc mức độ Cao/Khẩn cấp.
  bool get isUrgent =>
      shouldSeeDoctor ||
      urgencyLevel == UrgencyLevel.high ||
      urgencyLevel == UrgencyLevel.critical;
}
