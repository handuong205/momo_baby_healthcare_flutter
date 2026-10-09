import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pre_pregnancy/pre_pregnancy_header.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pre_pregnancy/pre_pregnancy_cycle_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pre_pregnancy/pre_pregnancy_fertility_card.dart';

class PrePregnancyScreen extends StatefulWidget {
  const PrePregnancyScreen({super.key});

  @override
  State<PrePregnancyScreen> createState() => _PrePregnancyScreenState();
}

class _PrePregnancyScreenState extends State<PrePregnancyScreen> {
  DateTime _lastPeriodDate = DateTime(2026, 10, 1);

  int _cycleLength = 28;

  final Set<String> _selectedSymptoms = {'Đau bụng nhẹ 🌸', 'Căng ngực 💧'};

  bool _isLoading = false;

  // ============================================================
  // GETTERS
  // ============================================================

  int get _ovulationDay => _cycleLength - 14;

  int get _fertileStartDay => (_ovulationDay - 3).clamp(1, _cycleLength);

  int get _fertileEndDay => (_ovulationDay + 2).clamp(1, _cycleLength);

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectLastPeriodDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      _lastPeriodDate = selectedDate;
    });
  }

  // ============================================================
  // CYCLE
  // ============================================================

  void _changeCycle(int value) {
    setState(() {
      _cycleLength = value.clamp(21, 45);
    });
  }

  // ============================================================
  // SYMPTOMS
  // ============================================================

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // TODO:
    // Gọi API lưu thông tin PrePregnancy.
    //
    // Chỉ navigate sang màn tiếp theo
    // khi API trả HTTP 200.

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã hoàn tất tính toán! 🎉')));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PrePregnancyHeader(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntro(),

                  const SizedBox(height: 16),

                  _buildReassurance(),

                  const SizedBox(height: 16),

                  PrePregnancyCycleCard(
                    lastPeriodDate: _lastPeriodDate,
                    cycleLength: _cycleLength,
                    selectedSymptoms: _selectedSymptoms,
                    onSelectDate: _selectLastPeriodDate,
                    onCycleChanged: _changeCycle,
                    onToggleSymptom: _toggleSymptom,
                  ),

                  const SizedBox(height: 16),

                  PrePregnancyFertilityCard(
                    cycleLength: _cycleLength,
                    fertileStartDay: _fertileStartDay,
                    fertileEndDay: _fertileEndDay,
                  ),

                  const SizedBox(height: 24),

                  _buildBottomAction(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),   
        ),

        const Text(
          'Chuẩn bị mang thai 🌸',
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
          'Theo dõi chu kỳ để tính ngày rụng trứng '
          'và thụ thai tối ưu',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REASSURANCE
  // ============================================================

  Widget _buildReassurance() {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'An tâm chuẩn bị',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Chào bạn! Hãy cùng MomOi lắng nghe '
                  'nhịp điệu tự nhiên của cơ thể nhé.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 30)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION
  // ============================================================

  Widget _buildBottomAction() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'MomOi AI đang phân tích...',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Hoàn tất & Tính ngày rụng trứng',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 10),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 15, color: AppColors.secondary),
            SizedBox(width: 5),
            Flexible(
              child: Text(
                'Dữ liệu sinh sản được mã hóa an toàn '
                'và bảo mật riêng tư tuyệt đối',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
