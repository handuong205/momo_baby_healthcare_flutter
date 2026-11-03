import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class BabyNicknameInput extends StatelessWidget {
  final TextEditingController controller;

  const BabyNicknameInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biệt danh của thai nhi',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '(Tùy chọn)',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          TextFormField(
            controller: controller,
            style: textTheme.bodyMedium,
            decoration: const InputDecoration(
              hintText:
                  'Ví dụ: Bé Bắp, Cún con, Đậu Đậu',
              prefixIcon: Icon(
                Icons.child_care,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}