import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PregnancyEdd extends StatelessWidget {
  final DateTime dueDate;
  final VoidCallback onTap;

  const PregnancyEdd({
    super.key,
    required this.dueDate,
    required this.onTap,
  });

  String get formattedDate {
    final day = dueDate.day
        .toString()
        .padLeft(2, '0');

    final month = dueDate.month
        .toString()
        .padLeft(2, '0');

    return '$day / $month / ${dueDate.year}';
  }

  int get daysRemaining {
    return dueDate
        .difference(DateTime.now())
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            const Text(
              'Ngày dự sinh (EDD) *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintLight,
                      borderRadius:
                          BorderRadius.circular(999),
                    ),
                    child: Text(
                      daysRemaining >= 0
                          ? 'Còn $daysRemaining ngày'
                          : 'Đã qua ngày dự sinh',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.calmTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}