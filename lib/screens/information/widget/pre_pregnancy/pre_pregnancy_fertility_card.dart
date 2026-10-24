import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PrePregnancyFertilityCard extends StatelessWidget {
  final int cycleLength;
  final int fertileStartDay;
  final int fertileEndDay;

  const PrePregnancyFertilityCard({
    super.key,
    required this.cycleLength,
    required this.fertileStartDay,
    required this.fertileEndDay,
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // TITLE
          // ========================================================

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.yellowLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes,
                  size: 24,
                  color: AppColors.warningYellow,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DỰ BÁO SƠ BỘ',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Cửa sổ thụ thai vàng',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ========================================================
          // CYCLE VISUAL
          // ========================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ngày 1 - Kinh nguyệt',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    Text(
                      'Ngày $fertileStartDay - '
                      '$fertileEndDay: Cao điểm',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),

                    Text(
                      'Ngày $cycleLength',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _buildCycleBar(),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Flexible(
                      child: Text(
                        'Khoảng ngày $fertileStartDay - '
                        '$fertileEndDay của chu kỳ: '
                        'Giai đoạn thụ thai vàng 💖',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========================================================
          // DOCTOR ADVICE
          // ========================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👩‍⚕️', style: TextStyle(fontSize: 24)),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  '“Giai đoạn rụng trứng là thời điểm vàng '
                  'để thụ thai thành công. Hãy giữ tinh thần '
                  'thư giãn và bổ sung axit folic nhé!”',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleBar() {
    final fertileWidth = (fertileEndDay - fertileStartDay + 1) / cycleLength;

    final startWidth = (fertileStartDay - 1) / cycleLength;

    final endWidth = 1 - startWidth - fertileWidth;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(
              flex: _toFlex(startWidth),
              child: Container(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),

            Expanded(
              flex: _toFlex(fertileWidth),
              child: Container(color: AppColors.primary),
            ),

            Expanded(
              flex: _toFlex(endWidth),
              child: Container(color: AppColors.surface),
            ),
          ],
        ),
      ),
    );
  }

  int _toFlex(double value) {
    return (value * 1000).round().clamp(1, 1000);
  }
}
