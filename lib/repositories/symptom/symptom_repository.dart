import 'dart:convert';
import 'dart:typed_data';

import 'package:momo_baby_healthcare_flutter/models/symptom/symptom_analysis.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';

class SymptomRepository {
  /// Gemini phân tích mất 10–30 giây, dài hơn timeout mặc định 10 giây.
  static const _aiTimeout = Duration(seconds: 60);

  /// Mô tả tối thiểu (giống bản web).
  static const int minDescriptionLength = 10;

  /// POST /api/symptoms — gửi mô tả (+ ảnh nếu có) cho AI phân tích.
  /// Ảnh gửi dạng data URL base64, giống bản web; backend chuyển cho Gemini.
  static Future<SymptomAnalysis> analyze({
    required String description,
    Uint8List? imageBytes,
    String imageMimeType = 'image/jpeg',
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = 'data:$imageMimeType;base64,${base64Encode(imageBytes)}';
    }

    final response = await ApiService.post(
      '/api/symptoms',
      data: {
        'textDescription': description.trim(),
        'imageUrl': imageUrl,
        'imageMimeType': imageBytes != null ? imageMimeType : null,
      },
      timeout: _aiTimeout,
    );

    return SymptomAnalysis.fromJson(_data(response.data, 'Không thể phân tích triệu chứng'));
  }

  /// GET /api/symptoms — lịch sử, mới nhất trước.
  static Future<List<SymptomAnalysis>> history() async {
    final response = await ApiService.get('/api/symptoms');
    final body = Map<String, dynamic>.from(response.data as Map);
    final list = body['data'] as List? ?? [];
    return list
        .whereType<Map>()
        .map((e) => SymptomAnalysis.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// GET /api/symptoms/{id}
  static Future<SymptomAnalysis> getById(int id) async {
    final response = await ApiService.get('/api/symptoms/$id');
    return SymptomAnalysis.fromJson(_data(response.data, 'Không tìm thấy kết quả phân tích'));
  }

  static Map<String, dynamic> _data(Object? raw, String fallbackMessage) {
    final body = Map<String, dynamic>.from(raw as Map);
    if (body['success'] != true || body['data'] is! Map) {
      throw Exception(body['message'] ?? fallbackMessage);
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }
}
