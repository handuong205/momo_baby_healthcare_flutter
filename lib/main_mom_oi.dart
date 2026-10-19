import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/care_schedule/data/care_schedule_repository.dart';
import 'features/care_schedule/services/care_reminder_service.dart';
import 'navigation/app_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = SecureStorageService();
  final apiClient = ApiClient(storage);
  final authController = AuthController(AuthRepository(apiClient, storage));
  apiClient.onSessionExpired = () async {
    await authController.handleSessionExpired();
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Phiên đăng nhập đã hết hạn'),
          content: Text('Mẹ vui lòng đăng nhập lại để tiếp tục nhé.'),
        ),
      );
    });
  };
  await authController.init();
  await _initCareReminders(authController);
  runApp(
    MomOiApp(
      authController: authController,
      initialRoute: authController.isAuthenticated ? '/main' : '/landing',
    ),
  );
}

class MomOiApp extends StatelessWidget {
  const MomOiApp({
    super.key,
    required this.authController,
    required this.initialRoute,
  });

  final AuthController authController;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authController,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Mom Ơi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.momOi,
        initialRoute: initialRoute,
        onGenerateRoute: createRoute,
      ),
    );
  }
}

/// Chuông nhắc Lịch chăm sóc: chạm vào thông báo sẽ mở màn Lịch chăm sóc.
Future<void> _initCareReminders(AuthController authController) async {
  final reminders = CareReminderService.instance;
  void openSchedule(String? payload) {
    if (!(payload?.startsWith(CareReminderService.payloadPrefix) ?? false)) {
      return;
    }
    if (!authController.isAuthenticated) return;
    navigatorKey.currentState?.pushNamed('/care-schedule');
  }

  try {
    reminders.onNotificationTap = openSchedule;
    await reminders.init();
    // Đặt lại chuông theo lịch trên backend (lịch có thể được thêm từ app
    // Mobile / web); không chặn mở app nếu mạng chậm.
    if (authController.isAuthenticated) {
      unawaited(
        CareScheduleRepository(authController.repository.client)
            .list()
            .then(reminders.sync)
            .catchError(
              (Object e) => debugPrint('Không đồng bộ được chuông: $e'),
            ),
      );
    }
    final launch = await reminders.launchPayload();
    if (launch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => openSchedule(launch));
    }
  } catch (error) {
    debugPrint('Không khởi tạo được chuông nhắc: $error');
  }
}
