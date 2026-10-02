import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/models/auth/login_response.dart';
import 'package:momo_baby_healthcare_flutter/repositories/auth/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/login_screen.dart';


class HomeScreen extends StatelessWidget {
  final LoginResponse loginResult;

  const HomeScreen({
    super.key,
    required this.loginResult,
  });

  Future<void> _logout(BuildContext context) async {
    await AuthRepository.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = loginResult.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Đăng nhập thành công!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin user',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text('ID: ${user.id}'),

                    const SizedBox(height: 8),

                    Text('Email: ${user.email}'),

                    const SizedBox(height: 8),

                    Text('Tier: ${user.tier}'),

                    const SizedBox(height: 8),

                    Text(
                      'Roles: ${user.roles.join(', ')}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại Login Test'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
            ),
          ],
        ),
      ),
    );
  }
}