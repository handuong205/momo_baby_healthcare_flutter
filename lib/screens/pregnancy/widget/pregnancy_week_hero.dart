import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/pregnancy/pregnancy_models.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// Thẻ đầu màn Thai kỳ: tuần thai, tam cá nguyệt và tiến độ tới tuần 40.
class PregnancyWeekHero extends StatelessWidget {
  const PregnancyWeekHero({super.key, required this.info});

  final PregnancyWeekInfo info;

  static int trimesterOf(int week) {
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final week = info.week.clamp(0, 40);
    final trimester = trimesterOf(week);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientPink,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.hero),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MomTheme.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              'Tam cá nguyệt thứ $trimester',
              style: const TextStyle(
                color: MomTheme.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tuần thai thứ $week',
            style: const TextStyle(
              color: MomTheme.white,
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            week >= 40
                ? 'Bé đã đủ tháng, mẹ chú ý dấu hiệu chuyển dạ nhé.'
                : 'Còn ${40 - week} tuần nữa tới ngày dự sinh.',
            style: const TextStyle(
              color: MomTheme.white,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: week / 40,
              minHeight: 7,
              backgroundColor: MomTheme.white.withValues(alpha: 0.35),
              valueColor: const AlwaysStoppedAnimation(MomTheme.white),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tuần 0', style: _scaleStyle),
              Text('Tuần 40', style: _scaleStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const _scaleStyle = TextStyle(
    color: MomTheme.white,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
  );
}

/// Nội dung tuần này: kích thước bé, phát triển và lời khuyên cho mẹ.
class PregnancyWeekDetailCard extends StatelessWidget {
  const PregnancyWeekDetailCard({super.key, required this.info});

  final PregnancyWeekInfo info;

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, String label, String body})>[
      if (info.babySize?.isNotEmpty == true)
        (
          icon: LucideIcons.baby,
          label: 'Kích thước bé',
          body: 'Bé đang ${info.babySize}',
        ),
      if (info.development?.isNotEmpty == true)
        (
          icon: LucideIcons.sprout,
          label: 'Phát triển tuần này',
          body: info.development!,
        ),
      if (info.momTips?.isNotEmpty == true)
        (
          icon: LucideIcons.heartHandshake,
          label: 'Dành cho mẹ',
          body: info.momTips!,
        ),
    ];

    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: MomTheme.borderSoft),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: MomTheme.pinkLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(rows[i].icon, size: 17, color: MomTheme.roseDeep),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rows[i].label,
                        style: const TextStyle(
                          color: MomTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rows[i].body,
                        style: const TextStyle(
                          color: MomTheme.charcoalMid,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
