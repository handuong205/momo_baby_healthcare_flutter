import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/fertility/fertility_models.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// Trạng thái hôm nay theo `GET /api/fertility/ovulation-today`.
class OvulationStatusCard extends StatelessWidget {
  const OvulationStatusCard({super.key, required this.status});

  final OvulationStatus status;

  @override
  Widget build(BuildContext context) {
    final inWindow = status.isInFertileWindow;
    final headline = inWindow
        ? 'Hôm nay mẹ đang trong cửa sổ thụ thai vàng'
        : status.daysUntilOvulation > 0
        ? 'Còn ${status.daysUntilOvulation} ngày nữa tới ngày rụng trứng'
        : 'Chưa có dự đoán cho hôm nay';

    return MomCard(
      color: inWindow ? MomTheme.pinkLight : MomTheme.white,
      borderColor: inWindow ? MomTheme.pink : MomTheme.borderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: inWindow ? MomTheme.pink : MomTheme.roseDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  inWindow ? LucideIcons.sparkles : LucideIcons.moon,
                  size: 20,
                  color: inWindow ? MomTheme.roseDeep : MomTheme.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inWindow ? 'CỬA SỔ THỤ THAI' : 'DỰ BÁO HÔM NAY',
                      style: const TextStyle(
                        color: MomTheme.roseDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      headline,
                      style: const TextStyle(
                        color: MomTheme.charcoal,
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status.recommendation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MomTheme.cream2,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: Text(
                status.recommendation,
                style: const TextStyle(
                  color: MomTheme.charcoalMid,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tóm tắt ngày rụng trứng và ngày kinh dự đoán của tháng đang xem.
class CycleSummaryCard extends StatelessWidget {
  const CycleSummaryCard({
    super.key,
    required this.calendar,
    required this.monthLabel,
  });

  final FertilityCalendar calendar;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.calendarHeart,
                size: 17,
                color: MomTheme.roseDark,
              ),
              const SizedBox(width: 8),
              Text('Dự đoán $monthLabel', style: MomText.label),
            ],
          ),
          const SizedBox(height: 12),
          _Row(
            label: 'Ngày rụng trứng',
            value: _formatDate(calendar.ovulationDay),
            highlight: true,
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Cửa sổ thụ thai',
            value: calendar.fertileWindowDays.isEmpty
                ? 'Chưa có dữ liệu'
                : '${_formatDate(calendar.fertileWindowDays.first)}'
                      ' – ${_formatDate(calendar.fertileWindowDays.last)}',
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Kỳ kinh kế tiếp',
            value: _formatDate(calendar.periodPrediction),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa có dữ liệu';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label, style: MomText.muted)),
      const SizedBox(width: 12),
      Text(
        value,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: highlight ? MomTheme.roseDeep : MomTheme.charcoal,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
