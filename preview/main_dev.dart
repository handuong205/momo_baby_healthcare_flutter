// Màn dev để test riêng 3 chức năng mới, không cần đi qua login/trang chủ.
//
// Chạy trên Windows desktop (không vướng CORS của web):
//   flutter run -d windows -t preview/main_dev.dart \
//     --dart-define=DEV_EMAIL=me@example.com --dart-define=DEV_PASSWORD=123456
//
// Hoặc dùng token có sẵn:
//   flutter run -d windows -t preview/main_dev.dart --dart-define=DEV_TOKEN=eyJ...
//
// Không truyền gì thì app vẫn mở: các màn sẽ hiện đúng trạng thái lỗi/chưa
// thiết lập để kiểm tra phần UI đó.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/models/auth/login_request.dart';
import 'package:momo_baby_healthcare_flutter/repositories/auth/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/ovulation_calendar_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/epds_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/pregnancy_week_screen.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';
import 'package:momo_baby_healthcare_flutter/services/token_service.dart';

const _email = String.fromEnvironment('DEV_EMAIL');
const _password = String.fromEnvironment('DEV_PASSWORD');
const _token = String.fromEnvironment('DEV_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  await dotenv.load(fileName: '.env');
  ApiService.initialize();

  await _signInIfConfigured();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _DevShell(),
      ),
    ),
  );
}

Future<void> _signInIfConfigured() async {
  try {
    if (_token.isNotEmpty) {
      await TokenService.saveTokens(token: _token, refreshToken: '');
      debugPrint('[dev] đã nạp token từ --dart-define');
      return;
    }
    if (_email.isNotEmpty && _password.isNotEmpty) {
      await AuthRepository.login(
        LoginRequest(email: _email, password: _password),
      );
      debugPrint('[dev] đăng nhập $_email thành công');
      return;
    }
    final saved = await TokenService.hasToken();
    debugPrint(
      saved
          ? '[dev] dùng token đã lưu trên máy'
          : '[dev] chưa có token — các màn sẽ hiện trạng thái lỗi/chưa thiết lập',
    );
  } catch (e) {
    debugPrint('[dev] đăng nhập thất bại: $e');
  }
}

class _DevShell extends StatefulWidget {
  const _DevShell();

  @override
  State<_DevShell> createState() => _DevShellState();
}

class _DevShellState extends State<_DevShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MomTheme.cream,
    body: IndexedStack(
      index: _tab,
      children: const [
        OvulationCalendarScreen(),
        PregnancyWeekScreen(),
        EpdsScreen(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(
          label: '(4) Rụng trứng',
          icon: Icon(Icons.calendar_month_outlined),
        ),
        NavigationDestination(
          label: '(5) Thai kỳ',
          icon: Icon(Icons.pregnant_woman),
        ),
        NavigationDestination(
          label: '(6) EPDS',
          icon: Icon(Icons.favorite_outline),
        ),
      ],
    ),
  );
}
