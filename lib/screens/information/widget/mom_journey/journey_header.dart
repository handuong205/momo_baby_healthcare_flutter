import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class JourneyHeader extends StatelessWidget {
  const JourneyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌷'),
              SizedBox(width: 6),
              Text(
                'Cá nhân hóa cùng AI MomOi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Chào Mẹ! Hãy chọn giai đoạn hiện tại của Mẹ nhé 🌷',
          style: textTheme.headlineLarge?.copyWith(
            fontSize: 26,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'MomOi sẽ cá nhân hóa thực đơn ăn uống, lời khuyên y khoa và bài học phát triển phù hợp nhất cho Mẹ & Bé.',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}