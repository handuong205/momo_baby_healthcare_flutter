import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/fertility/fertility_models.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// Lưới lịch tháng: ngày rụng trứng, cửa sổ thụ thai và ngày kinh dự đoán
/// do backend trả về (`GET /api/fertility/calendar`).
class CycleMonthGrid extends StatelessWidget {
  const CycleMonthGrid({
    super.key,
    required this.month,
    required this.calendar,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime month;
  final FertilityCalendar? calendar;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          date: DateTime(month.year, month.month, day),
          calendar: calendar,
          isToday: DateUtils.isSameDay(
            DateTime(month.year, month.month, day),
            today,
          ),
        ),
    ];

    return MomCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              _MonthArrow(
                icon: LucideIcons.chevronLeft,
                label: 'Tháng trước',
                onTap: onPrevMonth,
              ),
              Expanded(
                child: Text(
                  'Tháng ${month.month} • ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MomTheme.charcoal,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _MonthArrow(
                icon: LucideIcons.chevronRight,
                label: 'Tháng sau',
                onTap: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: MomTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: cells,
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _LegendDot(color: MomTheme.roseDark, label: 'Rụng trứng'),
              _LegendDot(color: MomTheme.pink, label: 'Dễ thụ thai'),
              _LegendDot(color: MomTheme.amber, label: 'Kinh dự đoán'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.calendar,
    required this.isToday,
  });

  final DateTime date;
  final FertilityCalendar? calendar;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isOvulation = calendar?.isOvulation(date) ?? false;
    final isFertile = calendar?.isFertile(date) ?? false;
    final isPeriod = calendar?.isPeriod(date) ?? false;

    final background = isOvulation
        ? MomTheme.roseDark
        : isFertile
        ? MomTheme.pink
        : isPeriod
        ? MomTheme.amberLight
        : Colors.transparent;
    final foreground = isOvulation ? MomTheme.white : MomTheme.charcoal;

    final notes = [
      if (isOvulation) 'ngày rụng trứng',
      if (isFertile && !isOvulation) 'ngày dễ thụ thai',
      if (isPeriod) 'ngày kinh dự đoán',
    ];

    return Semantics(
      label: [
        'Ngày ${date.day}',
        if (isToday) 'hôm nay',
        ...notes,
      ].join(', '),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: MomTheme.roseDark, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: foreground,
              fontSize: 12.5,
              fontWeight: isOvulation || isToday
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, size: 19, color: MomTheme.charcoalMid),
    style: IconButton.styleFrom(
      backgroundColor: MomTheme.cream2,
      minimumSize: const Size(36, 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
    ),
    tooltip: label,
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: MomText.muted),
    ],
  );
}
