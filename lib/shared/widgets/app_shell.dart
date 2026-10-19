import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/home/home_screen.dart';
import 'app_bottom_nav.dart';

/// Khung chính sau đăng nhập, theo `TabNavigator.tsx` bên RN:
/// không có header chung, mỗi tab tự vẽ phần đầu của mình.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  // Thứ tự khớp với AppBottomNav.items. Tab chưa làm dùng màn tạm.
  final List<Widget> _screens = [
    const HomeScreen(),
    for (final item in AppBottomNav.items.skip(1))
      _ComingSoonTab(title: item.label, icon: item.activeIcon),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MomTheme.cream,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: MomTheme.pinkLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: MomTheme.roseDark),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: MomTheme.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tính năng đang được phát triển.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
