import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momo_baby_healthcare_flutter/repositories/care/care_schedule_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/care/care_schedule_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/splash_screen.dart';
import 'package:momo_baby_healthcare_flutter/services/care_reminder_service.dart';
import 'package:momo_baby_healthcare_flutter/services/token_service.dart';


import 'services/api_service.dart';
import 'core/theme/app_theme.dart'; 
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  await dotenv.load(
    fileName: '.env',
  );

  ApiService.initialize();
  await _initCareReminders();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MomBaby',
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

/// Chuông nhắc Lịch chăm sóc: chạm vào thông báo sẽ mở màn Lịch chăm sóc.
Future<void> _initCareReminders() async {
  final reminders = CareReminderService.instance;
  Future<void> openSchedule(String? payload) async {
    if (!(payload?.startsWith(CareReminderService.payloadPrefix) ?? false)) {
      return;
    }
    // Chưa đăng nhập thì để luồng splash/login xử lý như bình thường.
    if ((await TokenService.getToken())?.isNotEmpty != true) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => const CareScheduleScreen()),
    );
  }

  try {
    reminders.onNotificationTap = openSchedule;
    await reminders.init();
    // Đặt lại chuông theo lịch trên backend (lịch có thể được thêm từ nơi
    // khác); không chặn mở app nếu mạng chậm.
    if ((await TokenService.getToken())?.isNotEmpty == true) {
      unawaited(
        CareScheduleRepository.list()
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
