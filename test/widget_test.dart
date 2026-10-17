import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:momo_baby_healthcare_flutter/core/network/api_client.dart';
import 'package:momo_baby_healthcare_flutter/core/storage/secure_storage_service.dart';
import 'package:momo_baby_healthcare_flutter/features/auth/data/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/features/auth/presentation/login_screen.dart';
import 'package:momo_baby_healthcare_flutter/features/auth/state/auth_controller.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    final storage = SecureStorageService();
    final controller = AuthController(
      AuthRepository(ApiClient(storage), storage),
    );
    controller.isLoading = false;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Chào mừng trở lại! 🌸'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
