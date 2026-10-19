import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

/// Thanh trên cùng của màn Tổng quan, theo "Top Bar" trong
/// `DashboardScreen.tsx` bên React Native: avatar 🌸, lời chào,
/// nút Thông báo và nút Đăng xuất.
///
/// Không có nền riêng, nằm trên nền kem của màn hình như bản RN.
class AppHeader extends StatelessWidget {
  final String? userName;
  final bool hasPendingAlerts;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onLogoutTap;

  const AppHeader({
    super.key,
    this.userName,
    this.hasPendingAlerts = false,
    this.onProfileTap,
    this.onNotificationsTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (userName == null || userName!.trim().isEmpty)
        ? 'Mẹ yêu'
        : userName!;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MomTheme.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: MomTheme.white, width: 2),
                  ),
                  child: const Text('🌸', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Xin chào mẹ,',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: MomTheme.muted,
                        ),
                      ),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: MomTheme.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _ActionButton(
          tooltip: 'Thông báo',
          icon: Icons.notifications_none_rounded,
          iconSize: 20,
          iconColor: MomTheme.charcoalMid,
          background: MomTheme.white,
          borderColor: MomTheme.border,
          showDot: hasPendingAlerts,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          tooltip: 'Đăng xuất',
          icon: Icons.logout_rounded,
          iconSize: 18,
          iconColor: MomTheme.roseDark,
          background: MomTheme.pinkLight,
          borderColor: MomTheme.pink,
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color background;
  final Color borderColor;
  final bool showDot;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.background,
    required this.borderColor,
    this.showDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: CircleBorder(side: BorderSide(color: borderColor)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: iconSize, color: iconColor),
                if (showDot)
                  Positioned(
                    top: 9,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: MomTheme.roseDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
