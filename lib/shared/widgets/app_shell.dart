import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/symptom_check_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/home/home_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/baby/baby_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/journey/journey_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/tools/tools_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Trang chủ và Lộ trình tải lại mỗi khi quay về tab
          // (RN: useFocusEffect).
          HomeScreen(onSelectTab: _onNavTap, isActive: _currentIndex == 0),
          JourneyScreen(isActive: _currentIndex == 1),
          const BabyScreen(),
          const SymptomCheckScreen(), // Tab "AI": màn 10–12
          const ToolsScreen(), // Tab "Menu": màn 13–15
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
