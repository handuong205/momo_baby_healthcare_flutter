import '../../exceptions/api_exception.dart';
import '../../models/baby/baby_models.dart';
import '../../services/api_service.dart';

class BabyRepository {
  static Future<List<BabyProfile>> getProfiles() async {
    final body = await _body(ApiService.get('/api/baby/profiles'));
    return _list(body['data']).map(BabyProfile.fromJson).toList();
  }

  static Future<BabyProfile> createProfile({
    required String babyName,
    required DateTime dateOfBirth,
    required String gender,
    required double? weightKg,
    required double? heightCm,
    required List<String> allergies,
  }) async {
    return _profile(await _body(ApiService.post(
      '/api/baby/profile',
      data: _profilePayload(
        babyName,
        dateOfBirth,
        gender,
        weightKg,
        heightCm,
        allergies,
      ),
    )));
  }

  static Future<BabyProfile> updateProfile(
    int id, {
    required String babyName,
    required DateTime dateOfBirth,
    required String gender,
    required double? weightKg,
    required double? heightCm,
    required List<String> allergies,
  }) async {
    return _profile(await _body(ApiService.put(
      '/api/baby/$id',
      data: _profilePayload(
        babyName,
        dateOfBirth,
        gender,
        weightKg,
        heightCm,
        allergies,
      ),
    )));
  }

  static Future<GrowthEvaluation> logGrowth(
    int babyId, {
    required double weightKg,
    required double heightCm,
    required DateTime recordedAt,
  }) async {
    final body = await _body(ApiService.post(
      '/api/baby/$babyId/growth',
      data: {
        'weightKg': weightKg,
        'heightCm': heightCm,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
      },
    ));
    return GrowthEvaluation.fromJson(_map(body['data']));
  }

  static Future<void> deleteGrowth(int babyId, int recordId) async {
    await _body(ApiService.delete('/api/baby/$babyId/growth/$recordId'));
  }

  static Future<DailyMenu> getDailyMenu(int babyId, {bool force = false}) async {
    final body = await _body(ApiService.get(
      '/api/baby/$babyId/menu/daily',
      queryParameters: {'force': force},
    ));
    return DailyMenu.fromJson(_map(body['data']));
  }

  static Future<WeeklyMenu> getWeeklyMenu(int babyId, {bool force = false}) async {
    final body = await _body(ApiService.get(
      '/api/baby/$babyId/menu/weekly',
      queryParameters: {'force': force},
    ));
    return WeeklyMenu.fromJson(_map(body['data']));
  }

  static Map<String, dynamic> _profilePayload(
    String name,
    DateTime dob,
    String gender,
    double? weight,
    double? height,
    List<String> allergies,
  ) =>
      {
        'babyName': name.trim(),
        'dateOfBirth': DateTime.utc(dob.year, dob.month, dob.day).toIso8601String(),
        'gender': gender,
        'currentWeightKg': weight,
        'currentHeightCm': height,
        'allergies': allergies,
        'foodHistory': <String>[],
      };

  static Future<Map<String, dynamic>> _body(Future<dynamic> request) async {
    final response = await request;
    final raw = response.data;
    if (raw is! Map) {
      throw ApiException(message: 'Phản hồi từ server không hợp lệ.');
    }
    final body = Map<String, dynamic>.from(raw);
    if (body['success'] == false || body['isSuccess'] == false) {
      throw ApiException(
        message: '${body['message'] ?? 'Thao tác không thành công.'}',
        errorCode: body['errorCode']?.toString(),
      );
    }
    return body;
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<Map<String, dynamic>> _list(dynamic value) => value is List
      ? value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
      : const [];

  static BabyProfile _profile(Map<String, dynamic> body) =>
      BabyProfile.fromJson(_map(body['data']));
}
