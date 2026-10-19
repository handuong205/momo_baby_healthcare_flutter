import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/mom_ui.dart';

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.color, this.route);

  final String label;
  final IconData icon;
  final Color color;
  final String route;
}

const _healthItems = [
  _MenuItem('Hồ sơ mẹ', LucideIcons.user, MomTheme.roseDark, '/profile'),
  _MenuItem(
    'Nhật ký hằng ngày',
    LucideIcons.clipboardList,
    MomTheme.sageDark,
    '/daily-monitoring',
  ),
  _MenuItem(
    'Lịch uống thuốc',
    LucideIcons.pill,
    MomTheme.purple,
    '/medications',
  ),
  _MenuItem(
    'Thông báo',
    LucideIcons.bell,
    MomTheme.amberDark,
    '/notifications',
  ),
];

const _utilityItems = [
  _MenuItem(
    'Lịch chăm sóc',
    LucideIcons.alarmClock,
    MomTheme.roseDark,
    '/care-schedule',
  ),
  _MenuItem('Khẩn cấp', LucideIcons.lifeBuoy, MomTheme.danger, '/emergency'),
  _MenuItem('Thư giãn', LucideIcons.headphones, MomTheme.purple, '/relax'),
];

/// Tab "Menu": hệ sinh thái tiện ích của Mom Ơi.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MomTheme.cream,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 34, 20, 40),
        children: [
          const Text(
            'HỆ SINH THÁI TIỆN ÍCH',
            style: TextStyle(
              color: MomTheme.roseDark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const Text(
            'Chức năng Mom Ơi',
            style: TextStyle(
              color: MomTheme.charcoal,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Trọn bộ công cụ theo dõi sức khỏe và chăm sóc bé yêu 🌸',
            style: TextStyle(color: MomTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          const _Group('Sức khỏe của mẹ', _healthItems),
          const _Group('Tiện ích & An toàn', _utilityItems),
        ],
      ),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.items);

  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MomTheme.charcoal,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((item) => SizedBox(width: width, child: _Tile(item)))
                  .toList(),
            );
          },
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile(this.item);

  final _MenuItem item;

  @override
  Widget build(BuildContext context) => Material(
    color: MomTheme.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).pushNamed(item.route),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: MomTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: MomTheme.cream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 18, color: item.color),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: MomTheme.charcoal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
