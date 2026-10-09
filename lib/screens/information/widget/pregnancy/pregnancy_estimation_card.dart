import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PregnancyEstimationCard extends StatelessWidget {
  const PregnancyEstimationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBadge(),

          const SizedBox(height: 12),

          const Text(
            'Tuần thai thứ 14 • 2 ngày',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'Tam cá nguyệt thứ 2 (3 tháng giữa)',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          _buildTrimesterProgress(),

          const SizedBox(height: 12),

          _buildBabyCard(),

          const SizedBox(height: 10),

          _buildDoctorAdvice(),
        ],
      ),
    );
  }

  Widget _buildTopBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.primary,
              ),
              SizedBox(width: 4),
              Text(
                'Tính toán thông minh tức thì',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'Hôm nay',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTrimesterProgress() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _progressSegment(
                progress: 1,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _progressSegment(
                progress: 0.4,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _progressSegment(
                progress: 0,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TCN 1 (Đã qua)',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'TCN 2 (Hiện tại)',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              'TCN 3',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _progressSegment({
    required double progress,
  }) {
    return Container(
      height: 8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildBabyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.yellowLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🍋',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bé cỡ quả chanh tây (~45g)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Đang phát triển thính giác và bắt đầu có những cử động tay chân nhẹ nhàng.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorAdvice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.aiPurpleSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 18,
            color: AppColors.aiPurple,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Lời khuyên Bác sĩ: ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      height: 18 / 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.aiPurple,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Thời điểm vàng để thực hiện xét nghiệm sàng lọc định kỳ và tăng cường bổ sung Sắt, Canxi theo phác đồ.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      height: 18 / 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}