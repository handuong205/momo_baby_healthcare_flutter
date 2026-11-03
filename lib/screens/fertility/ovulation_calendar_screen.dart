import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/models/fertility/fertility_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/fertility/fertility_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/pre_pregnancy_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/widget/cycle_month_grid.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/widget/ovulation_status_card.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// (4) Lịch rụng trứng — tháng dự đoán + trạng thái hôm nay.
///
/// Dữ liệu lấy từ backend (`/api/fertility/calendar`, `/ovulation-today`);
/// app không tự tính chu kỳ để tránh lệch với hồ sơ đã lưu.
class OvulationCalendarScreen extends StatefulWidget {
  const OvulationCalendarScreen({super.key});

  @override
  State<OvulationCalendarScreen> createState() => _OvulationCalendarScreenState();
}

class _OvulationCalendarScreenState extends State<OvulationCalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  FertilityCalendar? _calendar;
  OvulationStatus? _status;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        FertilityRepository.calendar(_month),
        FertilityRepository.ovulationToday(),
      ]);
      if (!mounted) return;
      setState(() {
        _calendar = results[0] as FertilityCalendar;
        _status = results[1] as OvulationStatus;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiError.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
    _load();
  }

  /// Hồ sơ chưa có ngày kinh cuối thì backend từ chối — đưa mẹ sang màn thiết lập.
  bool get _needsCycleSetup =>
      _error is String && _error!.toLowerCase().contains('chu kỳ cuối cùng');

  Future<void> _openCycleSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrePregnancyScreen()),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = 'tháng ${_month.month}/${_month.year}';

    return MomScreen(
      eyebrow: 'Chu kỳ của mẹ',
      title: 'Lịch rụng trứng',
      subtitle: 'Dự đoán ngày rụng trứng và cửa sổ thụ thai theo chu kỳ của mẹ.',
      onRefresh: _load,
      children: [
        if (_loading)
          const MomLoadingView(text: 'Đang tải lịch dự đoán...')
        else if (_needsCycleSetup)
          MomStateCard(
            emoji: '🌸',
            title: 'Chưa có ngày kinh cuối',
            body: _error,
            action: MomPrimaryButton(
              label: 'Thiết lập chu kỳ',
              icon: LucideIcons.calendarPlus,
              onPressed: _openCycleSetup,
            ),
          )
        else if (_error != null)
          MomStateCard.error(_error!, onRetry: _load)
        else ...[
          if (_status != null) OvulationStatusCard(status: _status!),
          CycleMonthGrid(
            month: _month,
            calendar: _calendar,
            onPrevMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
          ),
          if (_calendar != null)
            CycleSummaryCard(calendar: _calendar!, monthLabel: monthLabel),
          MomCard(
            color: MomTheme.cream2,
            borderColor: MomTheme.border,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.info,
                  size: 16,
                  color: MomTheme.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ngày rụng trứng chỉ là dự đoán dựa trên độ dài chu kỳ. '
                    'Mẹ nên kết hợp que thử và dấu hiệu cơ thể để chính xác hơn.',
                    style: MomText.muted,
                  ),
                ),
              ],
            ),
          ),
          if (_needsCycleSetup == false && _calendar != null)
            MomSecondaryButton(
              label: 'Cập nhật ngày kinh cuối',
              icon: LucideIcons.refreshCw,
              onPressed: _openCycleSetup,
            ),
        ],
      ],
    );
  }
}
