import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';

class MainTabShell extends StatefulWidget {
  const MainTabShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  late int index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        repository: DashboardRepository(
          context.read<AuthController>().repository.client,
        ),
      ),
      const _PlaceholderTab(label: 'Lộ trình', icon: LucideIcons.heartPulse),
      const _PlaceholderTab(label: 'Bé yêu', icon: LucideIcons.baby),
      const _PlaceholderTab(label: 'AI', icon: LucideIcons.activity),
      const _PlaceholderTab(label: 'Menu', icon: LucideIcons.grid3X3),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryLight,
        height: 68,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            selectedIcon: Icon(LucideIcons.home),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.heartPulse),
            label: 'Lộ trình',
          ),
          NavigationDestination(icon: Icon(LucideIcons.baby), label: 'Bé yêu'),
          NavigationDestination(icon: Icon(LucideIcons.activity), label: 'AI'),
          NavigationDestination(icon: Icon(LucideIcons.grid3X3), label: 'Menu'),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    ),
  );
}
