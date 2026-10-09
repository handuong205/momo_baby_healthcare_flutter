import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pregnancy/pregnancy_progress_header.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pregnancy/pregnancy_lmp_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pregnancy/pregnancy_edd_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/pregnancy/pregnancy_estimation_card.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  DateTime _lmpDate = DateTime(2026, 1, 15);
  DateTime _eddDate = DateTime(2026, 10, 22);

  Future<void> _selectLmpDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lmpDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      _lmpDate = selectedDate;
    });
  }

  Future<void> _selectEddDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _eddDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) return;

    setState(() {
      _eddDate = selectedDate;
    });
  }

  void _startJourney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bắt đầu hành trình thai kỳ 🤰'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.primaryLight,
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Back button
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.surface,
                  elevation: 1,
                  shadowColor: Colors.black12,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PregnancyProgressHeader(),

                const SizedBox(height: 16),

                PregnancyLmpCard(
                  dateText: _formatDate(_lmpDate),
                  onChangeDate: _selectLmpDate,
                ),

                const SizedBox(height: 16),

                PregnancyEddCard(
                  dateText: _formatDate(_eddDate),
                  onChangeDate: _selectEddDate,
                ),

                const SizedBox(height: 16),

                const PregnancyEstimationCard(),

                const SizedBox(height: 12),

                _buildSecurityText(),

                const SizedBox(height: 12),

                _buildStartButton(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSecurityText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline,
          size: 15,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Thông tin thai kỳ của Mẹ được mã hóa & bảo mật y tế HIPAA',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _startJourney,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: const StadiumBorder(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bắt đầu hành trình thai kỳ',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}