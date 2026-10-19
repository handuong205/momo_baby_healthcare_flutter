import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/repositories/pregnancy/pregnancy_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/splash_screen.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/dialogs/app_result_dialog.dart';
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
  static final DateTime _today = DateUtils.dateOnly(DateTime.now());

  // Mặc định khoảng tuần thai 14, mẹ chọn lại ngày thật.
  DateTime _lmpDate = _today.subtract(const Duration(days: 13 * 7 + 2));

  /// Null = mẹ không nhập, dùng ngày dự sinh tự tính và để backend tự tính.
  DateTime? _manualEddDate;

  bool _isLoading = false;

  /// Ngày dự sinh = ngày kinh cuối + 280 ngày (quy tắc Naegele, giống RN).
  DateTime get _eddDate =>
      _manualEddDate ?? _lmpDate.add(const Duration(days: 280));

  int get _daysPregnant => _today.difference(_lmpDate).inDays;

  // Tuần thai tròn (0-based) + ngày lẻ, giới hạn tối đa 42 tuần như RN.
  int get _weeks => (_daysPregnant ~/ 7).clamp(0, 42);
  int get _days => _weeks >= 42 ? 0 : _daysPregnant % 7;

  Future<void> _selectLmpDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lmpDate,
      firstDate: _today.subtract(const Duration(days: 42 * 7)),
      lastDate: _today,
    );

    if (selectedDate == null) return;

    setState(() {
      _lmpDate = selectedDate;
    });
  }

  Future<void> _selectEddDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _eddDate.isBefore(_today) ? _today : _eddDate,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 300)),
    );

    if (selectedDate == null) return;

    setState(() {
      _manualEddDate = selectedDate;
    });
  }

  Future<void> _startJourney() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final message = await PregnancyRepository.setupPregnancy(
        lastMenstrualPeriod: _lmpDate,
        dueDate: _manualEddDate,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      await AppResultDialog.showSuccess(
        context,
        title: 'Thiết lập thai kỳ thành công! 🤰',
        message: [
          message.isNotEmpty ? message : 'Thông tin thai kỳ của mẹ đã được lưu.',
          'Mẹ đang ở tuần thai thứ $_weeks • $_days ngày.\n'
              'Ngày dự sinh: ${_formatDate(_eddDate)}',
        ].join('\n\n'),
        buttonText: 'Tiếp tục',
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi thiết lập thai kỳ: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => _isLoading = false);

      await AppResultDialog.showError(
        context,
        title: 'Không thể thiết lập',
        message: e is ApiException
            ? ApiError.getErrorMessage(e)
            : 'Không thể lưu thông tin thai kỳ. Vui lòng thử lại.',
        buttonText: 'Đóng',
      );
    }
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

                PregnancyEstimationCard(weeks: _weeks, days: _days),

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
        onPressed: _isLoading ? null : _startJourney,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLoading
                  ? 'Đang thiết lập thai kỳ...'
                  : 'Bắt đầu hành trình thai kỳ',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }
}