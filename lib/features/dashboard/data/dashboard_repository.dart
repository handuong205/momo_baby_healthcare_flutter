import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this.client);

  final ApiClient client;

  Future<MomProfile?> getProfile() async {
    final response = await client.dio.get(ApiConfig.profile);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'];
    return data is Map<String, dynamic> ? MomProfile.fromJson(data) : null;
  }

  Future<TodayMonitoring> getTodayMonitoring() async {
    final response = await client.dio.get(ApiConfig.dailyMonitoringToday);
    return TodayMonitoring.fromResponse(response.data as Map<String, dynamic>);
  }

  Future<int> getPendingAlerts() async {
    final response = await client.dio.get(ApiConfig.alerts);
    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! List) return 0;
    return (data['data'] as List)
        .whereType<Map<String, dynamic>>()
        .where((item) => item['status'] != 'Resolved')
        .length;
  }

  Future<PregnancyWeekInfo> getPregnancyWeek() async {
    final response = await client.dio.get(ApiConfig.pregnancyThisWeek);
    final body = response.data as Map<String, dynamic>;
    return PregnancyWeekInfo.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> saveMonitoring(Map<String, dynamic> payload) async {
    await client.dio.post(ApiConfig.dailyMonitoring, data: payload);
  }
}
