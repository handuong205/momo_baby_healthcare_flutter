import 'package:flutter/material.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/landing/presentation/landing_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/monitoring/presentation/daily_monitoring_screen.dart';
import '../features/medication/presentation/medication_screen.dart';
import '../features/care_schedule/presentation/care_schedule_screen.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/relax/presentation/relax_screen.dart';
import 'main_tab_shell.dart';

Route<dynamic> createRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/landing':
    case '/onboarding':
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const LandingScreen(),
      );
    case '/register':
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RegisterScreen(),
      );
    case '/main':
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => MainTabShell(
          initialIndex: settings.arguments is int
              ? settings.arguments as int
              : 0,
        ),
      );
    case '/profile':
      return MaterialPageRoute<void>(builder: (_) => const ProfileScreen());
    case '/notifications':
      return MaterialPageRoute<void>(
        builder: (_) => const NotificationsScreen(),
      );
    case '/daily-monitoring':
      return MaterialPageRoute<void>(
        builder: (_) => const DailyMonitoringScreen(),
      );
    case '/medications':
      return MaterialPageRoute<void>(builder: (_) => const MedicationScreen());
    case '/care-schedule':
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const CareScheduleScreen(),
      );
    case '/emergency':
      return MaterialPageRoute<void>(builder: (_) => const EmergencyScreen());
    case '/relax':
      return MaterialPageRoute<void>(builder: (_) => const RelaxScreen());
    case '/login':
    default:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const LoginScreen(),
      );
  }
}
