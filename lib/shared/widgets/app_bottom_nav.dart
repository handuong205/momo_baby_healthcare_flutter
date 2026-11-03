import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

/// Thanh tab dưới kiểu liquid glass, với 5 tab và màu theo
/// `TabNavigator.tsx` bên React Native (tab đang chọn màu roseDark).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<AppNavItem> items = [
    AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Tổng quan'),
    AppNavItem(icon: Icons.monitor_heart_outlined, activeIcon: Icons.monitor_heart_rounded, label: 'Lộ trình'),
    AppNavItem(icon: Icons.child_care_outlined, activeIcon: Icons.child_care_rounded, label: 'Bé yêu'),
    AppNavItem(icon: Icons.show_chart_rounded, activeIcon: Icons.show_chart_rounded, label: 'AI'),
    AppNavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: GlassTabBar.bottom(
          tabs: items.map((item) {
            return GlassTab(
              icon: Icon(
                item.icon,
                color: MomTheme.mutedLight,
              ),
              activeIcon: Icon(
                item.activeIcon,
                color: MomTheme.roseDark,
              ),
              label: item.label,
              glowColor: MomTheme.roseDark,
            );
          }).toList(),
          selectedIndex: currentIndex,
          onTabSelected: onTap,
        ),
      ),
    );
  }
}

class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
