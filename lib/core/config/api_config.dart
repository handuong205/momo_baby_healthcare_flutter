class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'MOMOI_API_BASE_URL',
    defaultValue: 'https://momoi-api-production.up.railway.app',
  );
  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const refresh = '/api/auth/refresh';
  static const logout = '/api/auth/logout';
  static const profile = '/api/user-profile';
  static const dailyMonitoringToday = '/api/daily-monitoring/today';
  static const dailyMonitoring = '/api/daily-monitoring';
  static const alerts = '/api/alerts';
  static const pregnancyThisWeek = '/api/pregnancy/this-week';
  static const medications = '/api/medications';
  static String medicationAdherence(Object id) =>
      '/api/medications/$id/adherence';
  static String medicationById(Object id) => '/api/medications/$id';
  static String alertStatus(Object id) => '/api/alerts/$id/status';
  static const pregnancyWeightLog = '/api/pregnancy/weight-log';
  static const lifestyleToday = '/api/lifestyle/today';
  static const lifestyleEntry = '/api/lifestyle/entry';
}
