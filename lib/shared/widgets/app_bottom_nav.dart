import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.cottage_rounded,
      label: 'Trang chủ',
    ),
    _NavItem(
      icon: Icons.restaurant_menu_rounded,
      label: 'Ăn uống',
    ),
    _NavItem(
      icon: Icons.auto_stories_rounded,
      label: 'Nhật ký con',
    ),
    _NavItem(
      icon: Icons.support_agent_rounded,
      label: 'Bác sĩ ơi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: GlassTabBar.bottom(
          tabs: _items.map((item) {
            return GlassTab(
              icon: Icon(
                item.icon,
                color: AppColors.onSurfaceVariant,
              ),
              activeIcon: Icon(
                item.icon,
                color: AppColors.primary,
              ),
              label: item.label,
              glowColor: AppColors.primary,
            );
          }).toList(),
          selectedIndex: currentIndex,
          onTabSelected: onTap,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}