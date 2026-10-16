import 'package:flutter/foundation.dart';

import '../data/dashboard_repository.dart';
import '../models/dashboard_models.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this.repository);

  final DashboardRepository repository;
  MomProfile? profile;
  PregnancyWeekInfo? weekInfo;
  int waterCups = 0;
  int? moodScore;
  double? sleepHours;
  int pendingAlerts = 0;
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final results = await Future.wait([
      _safe(repository.getProfile),
      _safe(repository.getTodayMonitoring),
      _safe(repository.getPendingAlerts),
    ]);
    profile = results[0] as MomProfile?;
    final monitoring = results[1] as TodayMonitoring?;
    if (monitoring != null) {
      waterCups = ((monitoring.waterLiters ?? 0) / 0.25).round();
      moodScore = monitoring.moodScore;
      sleepHours = monitoring.sleepHours;
    }
    pendingAlerts = results[2] as int? ?? 0;
    if (stage == 1) {
      weekInfo = await _safe(repository.getPregnancyWeek);
    } else {
      weekInfo = null;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addWater() async {
    if (waterCups >= 20) {
      throw const DashboardActionException(
        'Tuyệt vời!',
        'Mẹ đã uống rất nhiều nước hôm nay rồi.',
      );
    }
    final previous = waterCups;
    waterCups++;
    notifyListeners();
    try {
      await repository.saveMonitoring({'waterLiters': waterCups * 0.25});
    } catch (error) {
      waterCups = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> chooseMood(int score) async {
    final previous = moodScore;
    moodScore = score;
    notifyListeners();
    try {
      final option = moodOptions.firstWhere((item) => item.score == score);
      await repository.saveMonitoring({
        'moodScore': score,
        'moodNote': option.label,
      });
    } catch (error) {
      moodScore = previous;
      notifyListeners();
      rethrow;
    }
  }

  int get stage {
    if (profile?.stage == 1 || profile?.stage == 'Pregnant') return 1;
    if (profile?.stage == 2 || profile?.stage == 'Postpartum') return 2;
    return 0;
  }

  bool get needsSetup =>
      profile != null &&
      profile!.lastPeriodDate == null &&
      profile!.deliveryDate == null &&
      profile!.height == null &&
      profile!.weight == null;

  Future<T?> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      debugPrint('[DashboardController] request failed: $error');
      return null;
    }
  }
}

class DashboardActionException implements Exception {
  const DashboardActionException(this.title, this.message);

  final String title;
  final String message;
}
