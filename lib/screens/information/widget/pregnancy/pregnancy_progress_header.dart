import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PregnancyProgressHeader extends StatelessWidget {
  const PregnancyProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        const Text(
          'Đang mang thai🤰',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Theo dõi tuần thai và đồng hành dinh dưỡng trọn vẹn cùng bé yêu',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.verified, size: 18, color: AppColors.calmTeal),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tính toán chuẩn Sản khoa Quốc tế (ACOG & WHO)',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
