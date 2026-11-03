import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/models/symptom/symptom_analysis.dart';

/// Nhãn và màu theo mức độ khẩn cấp.
class UrgencyStyle {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const UrgencyStyle(this.label, this.icon, this.color, this.background);

  static UrgencyStyle of(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.low:
        return const UrgencyStyle('Thấp', Icons.sentiment_satisfied_rounded, MomTheme.sageDark, MomTheme.sageLight);
      case UrgencyLevel.medium:
        return const UrgencyStyle('Trung bình', Icons.info_rounded, MomTheme.amberDark, AppColors.amberLight);
      case UrgencyLevel.high:
        return const UrgencyStyle('Cao', Icons.warning_rounded, AppColors.rose, AppColors.roseLight);
      case UrgencyLevel.critical:
        return const UrgencyStyle('Khẩn cấp', Icons.emergency_rounded, Color(0xFFB3261E), Color(0xFFFFE4E1));
      case UrgencyLevel.unknown:
        return const UrgencyStyle('Chưa xác định', Icons.help_outline_rounded, MomTheme.muted, MomTheme.cream2);
    }
  }
}

class UrgencyChip extends StatelessWidget {
  final UrgencyLevel level;

  const UrgencyChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final s = UrgencyStyle.of(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: s.background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 16, color: s.color),
          const SizedBox(width: 5),
          Text(
            s.label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: s.color,
            ),
          ),
        ],
      ),
    );
  }
}
