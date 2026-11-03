import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PregnancyWeekPicker extends StatelessWidget {
  final int currentWeek;
  final ValueChanged<int> onWeekChanged;

  const PregnancyWeekPicker({
    super.key,
    required this.currentWeek,
    required this.onWeekChanged,
  });

  String get monthLabel {
    if (currentWeek <= 4) return 'Tháng thứ 1';
    if (currentWeek <= 8) return 'Tháng thứ 2';
    if (currentWeek <= 13) return 'Tháng thứ 3';
    if (currentWeek <= 17) return 'Tháng thứ 4';
    if (currentWeek <= 21) return 'Tháng thứ 5';
    if (currentWeek <= 26) return 'Tháng thứ 6';
    if (currentWeek <= 30) return 'Tháng thứ 7';
    if (currentWeek <= 35) return 'Tháng thứ 8';

    return 'Tháng thứ 9';
  }

  @override
  Widget build(BuildContext context) {
    return _JourneyInputCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tuần thai hiện tại *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(
                    999,
                  ),
                ),
                child: Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: () {
                    onWeekChanged(
                      currentWeek - 1,
                    );
                  },
                ),

                Text(
                  'Tuần $currentWeek',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                _CircleButton(
                  icon: Icons.add,
                  onTap: () {
                    onWeekChanged(
                      currentWeek + 1,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.yellowLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🥭'),
                SizedBox(width: 6),
                Text(
                  'Bé bằng quả xoài ngọt ngào (~190g)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _JourneyInputCard extends StatelessWidget {
  final Widget child;

  const _JourneyInputCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}