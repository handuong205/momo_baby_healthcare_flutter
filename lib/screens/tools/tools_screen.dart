import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/care/care_schedule_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/emergency/emergency_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/ovulation_calendar_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/epds_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/pregnancy_week_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/relax/relax_screen.dart';

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.color, this.builder);

  final String label;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

final _utilityItems = [
  _MenuItem(
    'Lịch chăm sóc',
    LucideIcons.alarmClock,
    MomTheme.roseDark,
    (_) => const CareScheduleScreen(),
  ),
  _MenuItem(
    'Khẩn cấp',
    LucideIcons.lifeBuoy,
    MomTheme.danger,
    (_) => const EmergencyScreen(),
  ),
  _MenuItem(
    'Thư giãn',
    LucideIcons.headphones,
    MomTheme.purple,
    (_) => const RelaxScreen(),
  ),
];

final _journeyItems = [
  _MenuItem(
    'Lịch rụng trứng',
    LucideIcons.calendarHeart,
    MomTheme.roseDark,
    (_) => const OvulationCalendarScreen(),
  ),
  _MenuItem(
    'Thai kỳ theo tuần',
    LucideIcons.baby,
    MomTheme.purple,
    (_) => const PregnancyWeekScreen(),
  ),
  _MenuItem(
    'Hồi phục & EPDS',
    LucideIcons.brain,
    MomTheme.sageDark,
    (_) => const EpdsScreen(),
  ),
];

/// Tab "Menu": tiện ích & an toàn (màn 13–15).
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
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
        _Group('Hành trình của mẹ', _journeyItems),
        _Group('Tiện ích & An toàn', _utilityItems),
      ],
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
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: item.builder)),
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
