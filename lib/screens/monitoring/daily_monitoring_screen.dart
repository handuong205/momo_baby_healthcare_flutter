import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/models/monitoring/daily_monitoring.dart';
import 'package:momo_baby_healthcare_flutter/repositories/dashboard/dashboard_repository.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

const _sleepQualityOptions = [
  MoodOption(1, '😞', 'Rất tệ'),
  MoodOption(2, '😐', 'Chập chờn'),
  MoodOption(3, '🙂', 'Tạm ổn'),
  MoodOption(4, '😊', 'Ngon giấc'),
  MoodOption(5, '😴', 'Rất sâu'),
];

const _decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

String _formatNumber(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// Trả về chuỗi rỗng khi chưa có số đo (0 cũng coi như chưa đo, giống RN).
String _fieldText(num? value) =>
    value == null || value == 0 ? '' : _formatNumber(value);

double? _parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

/// Nhật ký đầy đủ trong ngày, port từ `DailyMonitoringScreen.tsx` bên RN, thêm
/// phần xu hướng 7 ngày gần đây (`history` + `insights`).
class DailyMonitoringScreen extends StatefulWidget {
  const DailyMonitoringScreen({super.key});

  @override
  State<DailyMonitoringScreen> createState() => _DailyMonitoringScreenState();
}

class _DailyMonitoringScreenState extends State<DailyMonitoringScreen> {
  final _moodNote = TextEditingController();
  final _bpHigh = TextEditingController();
  final _bpLow = TextEditingController();
  final _bloodSugar = TextEditingController();
  final _weight = TextEditingController();
  final _symptomNote = TextEditingController();

  bool _loaded = false;
  String? _loadError;
  bool _saving = false;

  double _sleepHours = 7;

  /// RN luôn gửi `sleepHours` nên mẹ không nhập vẫn bị ghi 7 giờ. Ở đây chỉ gửi
  /// khi đã có số liệu hoặc mẹ đã chỉnh, tránh lưu số giấc ngủ không có thật.
  bool _hasSleep = false;
  int? _sleepQuality;
  int _cups = 0;
  bool _breakfast = false;
  bool _lunch = false;
  bool _dinner = false;
  int? _moodScore;
  int _symptomSeverity = 0;

  List<DailyMonitoringLog> _history = const [];
  MonitoringInsights? _insights;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _moodNote.dispose();
    _bpHigh.dispose();
    _bpLow.dispose();
    _bloodSugar.dispose();
    _weight.dispose();
    _symptomNote.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      final log = await DashboardRepository.getTodayLog();
      if (!mounted) return;
      setState(() {
        if (log != null) _apply(log);
        _loaded = true;
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = ApiError.getErrorMessage(e));
      return;
    }
    await _loadTrends();
  }

  /// Phần xu hướng chỉ để tham khảo: lỗi thì ẩn đi, không chặn việc ghi nhật ký.
  Future<void> _loadTrends() async {
    try {
      final results = await Future.wait<Object?>([
        DashboardRepository.getMonitoringHistory(),
        DashboardRepository.getMonitoringInsights(),
      ]);
      if (!mounted) return;
      setState(() {
        _history = results[0] as List<DailyMonitoringLog>;
        _insights = results[1] as MonitoringInsights?;
      });
    } catch (e) {
      debugPrint('Không tải được xu hướng nhật ký: $e');
    }
  }

  void _apply(DailyMonitoringLog log) {
    if (log.sleepHours != null) {
      _sleepHours = log.sleepHours!;
      _hasSleep = true;
    }
    _sleepQuality = log.sleepQuality;
    _cups = cupsFromLiters(log.waterLiters);
    _breakfast = log.hadBreakfast;
    _lunch = log.hadLunch;
    _dinner = log.hadDinner;
    _moodScore = log.moodScore;
    // Trang chủ lưu nhãn tâm trạng vào `moodNote`: không hiện lại như ghi chú.
    final note = log.moodNote ?? '';
    _moodNote.text = moodOptions.any((m) => m.label == note) ? '' : note;
    _bpHigh.text = _fieldText(log.bloodPressureHigh);
    _bpLow.text = _fieldText(log.bloodPressureLow);
    _bloodSugar.text = _fieldText(log.bloodSugar);
    _weight.text = _fieldText(log.weight);
    _symptomSeverity = log.symptomSeverity ?? 0;
    _symptomNote.text = log.symptomNote ?? '';
  }

  Future<void> _save() async {
    final high = _parseNumber(_bpHigh.text);
    final low = _parseNumber(_bpLow.text);
    if ((high == null) != (low == null)) {
      await showMomAlert(
        context,
        'Huyết áp chưa đủ',
        'Mẹ nhập cả chỉ số tâm thu và tâm trương (VD: 110 / 70) nhé.',
      );
      return;
    }
    if (high != null &&
        low != null &&
        (high < 60 || high > 250 || low < 30 || low > 150 || low >= high)) {
      await showMomAlert(
        context,
        'Kiểm tra lại',
        'Chỉ số huyết áp chưa hợp lý. VD: 110 / 70 mmHg.',
      );
      return;
    }

    final moodNote = _moodNote.text.trim();
    final symptomNote = _symptomNote.text.trim();
    final moodLabel = moodOptions
        .where((m) => m.score == _moodScore)
        .firstOrNull
        ?.label;

    // Trường null không gửi lên thì backend giữ nguyên giá trị cũ.
    final payload = <String, dynamic>{
      if (_hasSleep) 'sleepHours': _sleepHours,
      'sleepQuality': ?_sleepQuality,
      'waterLiters': _cups * litersPerCup,
      'hadBreakfast': _breakfast,
      'hadLunch': _lunch,
      'hadDinner': _dinner,
      'moodScore': ?_moodScore,
      'moodNote': ?(moodNote.isNotEmpty ? moodNote : moodLabel),
      'bloodPressureHigh': ?high?.round(),
      'bloodPressureLow': ?low?.round(),
      'bloodSugar': ?_parseNumber(_bloodSugar.text),
      'weight': ?_parseNumber(_weight.text),
      'symptomSeverity': _symptomSeverity,
      if (symptomNote.isNotEmpty) 'symptomNote': symptomNote,
    };

    setState(() => _saving = true);
    try {
      await DashboardRepository.saveDailyMonitoring(payload);
      if (!mounted) return;
      await showMomAlert(
        context,
        'Đã lưu',
        'Nhật ký sức khỏe hôm nay đã được ghi nhận.',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        await showMomAlert(
          context,
          'Chưa lưu được',
          ApiError.getErrorMessage(e),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const eyebrow = 'Theo dõi hằng ngày';
    const title = 'Nhật ký hôm nay';
    const subtitle =
        'Chỉ mất khoảng 1 phút. Mẹ có thể lưu nhiều lần trong ngày, số liệu mới sẽ ghi đè.';

    if (_loadError != null || !_loaded) {
      return MomScreen(
        eyebrow: eyebrow,
        title: title,
        subtitle: subtitle,
        children: [
          if (_loadError != null)
            MomStateCard.error(_loadError!, onRetry: _load)
          else
            const MomLoadingView(),
        ],
      );
    }

    return MomScreen(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      children: [
        const MomSectionTitle(title: '😴 Giấc ngủ'),
        MomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Đêm qua mẹ ngủ bao lâu?', style: MomText.label),
              const SizedBox(height: 8),
              _Stepper(
                value: _sleepHours,
                step: 0.5,
                min: 0,
                max: 14,
                unit: 'giờ',
                onChanged: (value) => setState(() {
                  _sleepHours = value;
                  _hasSleep = true;
                }),
              ),
              const SizedBox(height: 14),
              const Text('Chất lượng giấc ngủ', style: MomText.label),
              const SizedBox(height: 8),
              _EmojiScale(
                options: _sleepQualityOptions,
                value: _sleepQuality,
                onChanged: (score) => setState(() => _sleepQuality = score),
              ),
            ],
          ),
        ),

        const MomSectionTitle(
          title: '💧 Uống nước',
          subtitle: '1 ly ≈ 250 ml · mục tiêu $dailyCupGoal ly (2,5 lít)',
        ),
        MomCard(
          child: _Stepper(
            value: _cups.toDouble(),
            step: 1,
            min: 0,
            max: 20,
            unit: 'ly',
            onChanged: (value) => setState(() => _cups = value.toInt()),
          ),
        ),

        const MomSectionTitle(title: '🍚 Bữa ăn'),
        MomCard(
          child: Column(
            children: [
              _ToggleRow(
                label: 'Bữa sáng',
                value: _breakfast,
                onChanged: (v) => setState(() => _breakfast = v),
              ),
              _ToggleRow(
                label: 'Bữa trưa',
                value: _lunch,
                onChanged: (v) => setState(() => _lunch = v),
              ),
              _ToggleRow(
                label: 'Bữa tối',
                value: _dinner,
                onChanged: (v) => setState(() => _dinner = v),
              ),
            ],
          ),
        ),

        const MomSectionTitle(title: '🌸 Tâm trạng'),
        MomCard(
          child: Column(
            children: [
              _EmojiScale(
                options: moodOptions,
                value: _moodScore,
                onChanged: (score) => setState(() => _moodScore = score),
              ),
              const SizedBox(height: 14),
              MomField(
                label: 'Ghi chú (không bắt buộc)',
                controller: _moodNote,
                hint: 'Hôm nay mẹ thấy thế nào?',
              ),
            ],
          ),
        ),

        const MomSectionTitle(
          title: '🩺 Chỉ số cơ thể',
          subtitle: 'Không bắt buộc, nhập nếu mẹ có đo',
        ),
        MomCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: MomField(
                      label: 'Tâm thu (mmHg)',
                      controller: _bpHigh,
                      hint: '110',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MomField(
                      label: 'Tâm trương (mmHg)',
                      controller: _bpLow,
                      hint: '70',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: MomField(
                      label: 'Đường huyết (mmol/L)',
                      controller: _bloodSugar,
                      hint: '5.1',
                      keyboardType: _decimalKeyboard,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MomField(
                      label: 'Cân nặng (kg)',
                      controller: _weight,
                      hint: '55',
                      keyboardType: _decimalKeyboard,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const MomSectionTitle(title: '🤒 Triệu chứng'),
        MomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mức độ khó chịu: $_symptomSeverity / 5',
                style: MomText.label,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var level = 0; level <= 5; level++)
                    _SeverityDot(
                      level: level,
                      active: _symptomSeverity == level,
                      onTap: () => setState(() => _symptomSeverity = level),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              MomField(
                label: 'Mô tả (không bắt buộc)',
                controller: _symptomNote,
                hint: 'VD: hơi đau lưng buổi chiều',
                multiline: true,
              ),
            ],
          ),
        ),

        MomPrimaryButton(
          label: 'Lưu nhật ký hôm nay',
          loading: _saving,
          onPressed: _save,
        ),
        const SizedBox(height: 20),

        if (_insights != null) ...[
          const MomSectionTitle(title: '📈 Xu hướng 7 ngày'),
          _InsightsCard(insights: _insights!),
        ],
        if (_history.isNotEmpty) ...[
          const MomSectionTitle(title: '🗓️ Những ngày gần đây'),
          MomCard(
            child: Column(
              children: [for (final log in _history) _HistoryRow(log: log)],
            ),
          ),
        ],
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final double value;
  final double step;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _Stepper({
    required this.value,
    required this.step,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  Widget _button(IconData icon, String tooltip, double next) => IconButton(
    tooltip: tooltip,
    onPressed: () => onChanged(next.clamp(min, max)),
    style: IconButton.styleFrom(
      backgroundColor: MomTheme.pinkLight,
      fixedSize: const Size(44, 44),
    ),
    icon: Icon(icon, size: 18, color: MomTheme.roseDark),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _button(LucideIcons.minus, 'Giảm', value - step),
        Text.rich(
          TextSpan(
            text: _formatNumber(value),
            style: const TextStyle(
              color: MomTheme.charcoal,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: MomTheme.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _button(LucideIcons.plus, 'Tăng', value + step),
      ],
    );
  }
}

class _EmojiScale extends StatelessWidget {
  final List<MoodOption> options;
  final int? value;
  final ValueChanged<int> onChanged;

  const _EmojiScale({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in options)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.control),
              onTap: () => onChanged(option.score),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: value == option.score ? MomTheme.pinkLight : null,
                  borderRadius: BorderRadius.circular(AppRadii.control),
                  border: Border.all(
                    color: value == option.score
                        ? MomTheme.rose
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 2),
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: value == option.score
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: value == option.score
                            ? MomTheme.roseDeep
                            : MomTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: MomText.body)),
        Switch.adaptive(
          value: value,
          activeTrackColor: MomTheme.roseDark,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SeverityDot extends StatelessWidget {
  final int level;
  final bool active;
  final VoidCallback onTap;

  const _SeverityDot({
    required this.level,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? MomTheme.roseDark : MomTheme.creamSoft,
      shape: CircleBorder(
        side: BorderSide(color: active ? MomTheme.roseDark : MomTheme.border),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Text(
              '$level',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? MomTheme.white : MomTheme.charcoalMid,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final MonitoringInsights insights;

  const _InsightsCard({required this.insights});

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label, style: MomText.body)),
        Text(value, style: MomText.label),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng hợp từ ${insights.totalDays} ngày mẹ đã ghi',
            style: MomText.muted,
          ),
          const SizedBox(height: 6),
          _row('Giấc ngủ trung bình', '${insights.averageSleepHours} giờ'),
          _row('Nước trung bình', '${insights.averageWaterLiters} lít'),
          _row('Tâm trạng trung bình', '${insights.averageMoodScore} / 5'),
          _row('Ăn đủ bữa', '${insights.mealConsistencyPercent}%'),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final DailyMonitoringLog log;

  const _HistoryRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final date = log.date;
    final mood = moodOptions.where((m) => m.score == log.moodScore).firstOrNull;
    final details = [
      if (log.sleepHours != null) '${_formatNumber(log.sleepHours!)} giờ ngủ',
      '${cupsFromLiters(log.waterLiters)} ly nước',
      if (mood != null) mood.label,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              date == null
                  ? '—'
                  : '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}',
              style: MomText.label,
            ),
          ),
          Expanded(child: Text(details, style: MomText.muted)),
        ],
      ),
    );
  }
}
