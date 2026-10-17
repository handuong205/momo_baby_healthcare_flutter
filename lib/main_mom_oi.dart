import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/state/auth_controller.dart';
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
