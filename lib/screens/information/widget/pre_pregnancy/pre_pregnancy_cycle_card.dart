import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class PrePregnancyCycleCard extends StatelessWidget {
  final DateTime lastPeriodDate;
  final int cycleLength;
  final Set<String> selectedSymptoms;

  final VoidCallback onSelectDate;
  final ValueChanged<int> onCycleChanged;
  final ValueChanged<String> onToggleSymptom;

  const PrePregnancyCycleCard({
    super.key,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.selectedSymptoms,
    required this.onSelectDate,
    required this.onCycleChanged,
    required this.onToggleSymptom,
  });

  static const List<String> symptoms = [
    'Đau bụng nhẹ 🌸',
    'Căng ngực 💧',
    'Mệt mỏi 😴',
    'Thay đổi tâm trạng ✨',
    'Đau mỏi lưng 🌿',
    'Thân nhiệt tăng nhẹ 🌡️',
  ];

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateCard(),

        const SizedBox(height: 16),

        _buildCycleLengthCard(),

        const SizedBox(height: 16),

        _buildSymptomsCard(),
      ],
    );
  }

  // ============================================================
  // CARD 1 - DATE
  // ============================================================

  Widget _buildDateCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconContainer(Icons.calendar_today),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Ngày đầu kỳ kinh gần nhất *',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              _buildBadge('Bước 1/2'),
            ],
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: onSelectDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kỳ kinh gần nhất bắt đầu',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          _formatDate(lastPeriodDate),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.edit_calendar,
                    size: 17,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 4),

                  const Text(
                    'Thay đổi',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.warningYellow,
              ),

              SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Giúp xác định pha nang noãn và dự đoán '
                  'cửa sổ rụng trứng chính xác theo chuẩn y khoa.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    height: 1.4,
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

  // ============================================================
  // CARD 2 - CYCLE
  // ============================================================

  Widget _buildCycleLengthCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconContainer(Icons.timelapse),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Độ dài chu kỳ kinh nguyệt *',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const Icon(
                Icons.help_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMinusButton(),

                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '$cycleLength',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ngày',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mintLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Chu kỳ lý tưởng',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                _buildPlusButton(),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Thường dao động từ 21 - 35 ngày '
            '(Trung bình phổ biến là 28 ngày)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Chọn nhanh chu kỳ thông thường:',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildQuickCycle(26),
              const SizedBox(width: 8),
              _buildQuickCycle(28),
              const SizedBox(width: 8),
              _buildQuickCycle(30),
              const SizedBox(width: 8),
              _buildQuickCycle(32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinusButton() {
    final disabled = cycleLength <= 21;

    return InkWell(
      onTap: disabled ? null : () => onCycleChanged(cycleLength - 1),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.remove,
          color: disabled ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPlusButton() {
    return InkWell(
      onTap: cycleLength >= 45 ? null : () => onCycleChanged(cycleLength + 1),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildQuickCycle(int days) {
    final selected = cycleLength == days;

    return Expanded(
      child: InkWell(
        onTap: () => onCycleChanged(days),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$days ngày${selected && days == 28 ? ' ✨' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD 3 - SYMPTOMS
  // ============================================================

  Widget _buildSymptomsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconContainer(Icons.monitor_heart_outlined),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Triệu chứng thường gặp',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const Text(
                'Tùy chọn',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Padding(
            padding: EdgeInsets.only(left: 40),
            child: Text(
              'Chọn các dấu hiệu cơ thể báo hiệu sắp rụng trứng',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms.map((symptom) {
              final selected = selectedSymptoms.contains(symptom);

              return _buildSymptomChip(symptom: symptom, selected: selected);
            }).toList(),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.aiPurpleSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology, size: 18, color: AppColors.aiPurple),

                SizedBox(width: 8),

                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'MomOi AI phân tích:\n',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.aiPurple,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Thuật toán sẽ đối chiếu '
                              'triệu chứng thực tế để cá nhân hóa '
                              'dự báo cửa sổ rụng trứng.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip({required String symptom, required bool selected}) {
    return InkWell(
      onTap: () => onToggleSymptom(symptom),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 15,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),

            const SizedBox(width: 5),

            Text(
              symptom,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMMON
  // ============================================================

  Widget _buildCard({required Widget child}) {
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
      child: child,
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.primary),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
