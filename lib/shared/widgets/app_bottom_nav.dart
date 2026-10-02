import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.only(
        top: 4,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _items.length,
            (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.7)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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