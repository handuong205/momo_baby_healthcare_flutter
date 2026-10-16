import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/state/auth_controller.dart';

class DailyMonitoringScreen extends StatefulWidget {
  const DailyMonitoringScreen({super.key});
  @override
  State<DailyMonitoringScreen> createState() => _DailyMonitoringScreenState();
}

class _DailyMonitoringScreenState extends State<DailyMonitoringScreen> {
  final sleep = TextEditingController(text: '7');
  final moodNote = TextEditingController();
  final high = TextEditingController();
  final low = TextEditingController();
  final sugar = TextEditingController();
  final weight = TextEditingController();
  final symptomNote = TextEditingController();
  int cups = 0;
  int? sleepQuality;
  int? mood;
  int symptom = 0;
  bool breakfast = false, lunch = false, dinner = false;
  bool loading = true, saving = false;
  String? error;
  ApiClient get client => context.read<AuthController>().repository.client;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final c in [sleep, moodNote, high, low, sugar, weight, symptomNote]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final response = await client.dio.get(ApiConfig.dailyMonitoringToday);
      final data = (response.data as Map<String, dynamic>)['data'];
      if (data is Map<String, dynamic>) {
        setState(() {
          sleep.text = data['sleepHours']?.toString() ?? '7';
          cups = ((data['waterLiters'] as num? ?? 0) / .25).round();
          sleepQuality = (data['sleepQuality'] as num?)?.toInt();
          mood = (data['moodScore'] as num?)?.toInt();
          moodNote.text = data['moodNote']?.toString() ?? '';
          high.text = data['bloodPressureHigh']?.toString() ?? '';
          low.text = data['bloodPressureLow']?.toString() ?? '';
          sugar.text = data['bloodSugar']?.toString() ?? '';
          weight.text = data['weight']?.toString() ?? '';
          symptom = (data['symptomSeverity'] as num?)?.toInt() ?? 0;
          symptomNote.text = data['symptomNote']?.toString() ?? '';
          breakfast = data['hadBreakfast'] == true;
          lunch = data['hadLunch'] == true;
          dinner = data['hadDinner'] == true;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> save() async {
    final h = double.tryParse(high.text.replaceAll(',', '.'));
    final l = double.tryParse(low.text.replaceAll(',', '.'));
    if ((h == null) != (l == null)) {
      return message(
        'Huyết áp chưa đủ',
        'Mẹ nhập cả chỉ số tâm thu và tâm trương (VD: 110 / 70) nhé.',
      );
    }
    if (h != null &&
        l != null &&
        (h < 60 || h > 250 || l < 30 || l > 150 || l >= h)) {
      return message(
        'Kiểm tra lại',
        'Chỉ số huyết áp chưa hợp lý. VD: 110 / 70 mmHg.',
      );
    }
    setState(() => saving = true);
    try {
      await client.dio.post(
        ApiConfig.dailyMonitoring,
        data: {
          'sleepHours': double.tryParse(sleep.text.replaceAll(',', '.')),
          'sleepQuality': sleepQuality,
          'waterLiters': (cups * .25 * 100).round() / 100,
          'hadBreakfast': breakfast,
          'hadLunch': lunch,
          'hadDinner': dinner,
          'moodScore': mood,
          'moodNote': moodNote.text.trim().isEmpty
              ? null
              : moodNote.text.trim(),
          'bloodPressureHigh': h,
          'bloodPressureLow': l,
          'bloodSugar': double.tryParse(sugar.text.replaceAll(',', '.')),
          'weight': double.tryParse(weight.text.replaceAll(',', '.')),
          'symptomSeverity': symptom,
          'symptomNote': symptomNote.text.trim().isEmpty
              ? null
              : symptomNote.text.trim(),
        },
      );
      await message('Đã lưu', 'Nhật ký sức khỏe hôm nay đã được ghi nhận.');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await message('Chưa lưu được', e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> message(String title, String text) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(text.replaceFirst('Exception: ', '')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _MonitoringPage(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return _MonitoringPage(
        body: Center(
          child: TextButton(onPressed: load, child: const Text('Thử lại')),
        ),
      );
    }
    return _MonitoringPage(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _title('😴 Giấc ngủ'),
          _stepper(sleep, 'giờ', 0, 14, .5),
          _title('Chất lượng giấc ngủ'),
          _scores(5, sleepQuality, (v) => setState(() => sleepQuality = v)),
          _title('💧 Uống nước'),
          _stepperValue(
            '$cups ly',
            () => setState(() => cups = (cups + 1).clamp(0, 20)),
            () => setState(() => cups = (cups - 1).clamp(0, 20)),
          ),
          _title('🍚 Bữa ăn'),
          ..._toggles(),
          _title('🌸 Tâm trạng'),
          _scores(5, mood, (v) => setState(() => mood = v)),
          _field('Ghi chú (không bắt buộc)', moodNote),
          _title('🩺 Chỉ số cơ thể'),
          Row(
            children: [
              _number('Tâm thu', high),
              const SizedBox(width: 10),
              _number('Tâm trương', low),
            ],
          ),
          Row(
            children: [
              _number('Đường huyết (mmol/L)', sugar),
              const SizedBox(width: 10),
              _number('Cân nặng (kg)', weight),
            ],
          ),
          _title('🤒 Triệu chứng'),
          Text('Mức độ khó chịu: $symptom / 5'),
          Slider(
            value: symptom.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: (v) => setState(() => symptom = v.round()),
          ),
          _field('Mô tả (không bắt buộc)', symptomNote),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: saving ? null : save,
            child: saving
                ? const CircularProgressIndicator()
                : const Text('Lưu nhật ký hôm nay'),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
      ),
    ),
  );
  Widget _number(String label, TextEditingController c) =>
      Expanded(child: _field(label, c));
  Widget _stepper(
    TextEditingController c,
    String unit,
    double min,
    double max,
    double step,
  ) => _stepperValue(
    '${c.text} $unit',
    () {
      final v = (double.tryParse(c.text) ?? 0) + step;
      c.text = v.clamp(min, max).toString();
      setState(() {});
    },
    () {
      final v = (double.tryParse(c.text) ?? 0) - step;
      c.text = v.clamp(min, max).toString();
      setState(() {});
    },
  );
  Widget _stepperValue(String value, VoidCallback plus, VoidCallback minus) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: minus,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          IconButton(
            onPressed: plus,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      );
  Widget _scores(int count, int? selected, ValueChanged<int> onChange) => Wrap(
    spacing: 6,
    children: List.generate(
      count,
      (i) => ChoiceChip(
        label: Text('${i + 1}'),
        selected: selected == i + 1,
        onSelected: (_) => onChange(i + 1),
      ),
    ),
  );
  List<Widget> _toggles() => [
    SwitchListTile(
      title: const Text('Bữa sáng'),
      value: breakfast,
      onChanged: (v) => setState(() => breakfast = v),
    ),
    SwitchListTile(
      title: const Text('Bữa trưa'),
      value: lunch,
      onChanged: (v) => setState(() => lunch = v),
    ),
    SwitchListTile(
      title: const Text('Bữa tối'),
      value: dinner,
      onChanged: (v) => setState(() => dinner = v),
    ),
  ];
}

class _MonitoringPage extends StatelessWidget {
  const _MonitoringPage({required this.body});
  final Widget body;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(
      title: const Text('Nhật ký hôm nay'),
      backgroundColor: AppColors.cream,
    ),
    body: body,
  );
}
