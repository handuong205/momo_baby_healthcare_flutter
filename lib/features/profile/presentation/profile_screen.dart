import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/state/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final height = TextEditingController();
  final weight = TextEditingController();
  final cycle = TextEditingController(text: '28');
  int stage = 0;
  DateTime? lmp;
  DateTime? delivery;
  bool breastfeeding = true;
  bool loading = true;
  bool saving = false;
  String? error;

  ApiClient get client => context.read<AuthController>().repository.client;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    height.dispose();
    weight.dispose();
    cycle.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final response = await client.dio.get(ApiConfig.profile);
      final data = (response.data as Map<String, dynamic>)['data'];
      if (data is Map<String, dynamic>) {
        setState(() {
          stage = _stage(data['stage']);
          height.text = _text(data['height']);
          weight.text = _text(data['weight']);
          cycle.text = _text(data['avgCycleLength']).isEmpty
              ? '28'
              : _text(data['avgCycleLength']);
          lmp = _date(data['lastPeriodDate']);
          delivery = _date(data['deliveryDate']);
          breastfeeding = data['isBreastfeeding'] as bool? ?? true;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (exception) {
      setState(() {
        error = exception.toString();
        loading = false;
      });
    }
  }

  Future<void> pickDate(bool isDelivery) async {
    final value = await showDatePicker(
      context: context,
      initialDate: (isDelivery ? delivery : lmp) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: isDelivery ? 365 * 3 : 300),
      ),
      lastDate: DateTime.now(),
    );
    if (value == null) return;
    setState(() => isDelivery ? delivery = value : lmp = value);
  }

  Future<void> save() async {
    final h = double.tryParse(height.text.replaceAll(',', '.'));
    final w = double.tryParse(weight.text.replaceAll(',', '.'));
    if (height.text.isNotEmpty && (h == null || h < 50 || h > 250)) {
      return showMessage(
        'Kiểm tra lại thông tin',
        'Chiều cao cần nằm trong khoảng 50 - 250 cm.',
      );
    }
    if (weight.text.isNotEmpty && (w == null || w < 20 || w > 300)) {
      return showMessage(
        'Kiểm tra lại thông tin',
        'Cân nặng cần nằm trong khoảng 20 - 300 kg.',
      );
    }
    if (stage == 0 &&
        (int.tryParse(cycle.text) == null ||
            int.parse(cycle.text) < 20 ||
            int.parse(cycle.text) > 45)) {
      return showMessage(
        'Kiểm tra lại thông tin',
        'Độ dài chu kỳ thường từ 20 đến 45 ngày.',
      );
    }
    if (stage == 1 && lmp == null) {
      return showMessage(
        'Kiểm tra lại thông tin',
        'Mẹ chọn ngày đầu kỳ kinh cuối để tính tuần thai nhé.',
      );
    }
    if (stage == 2 && delivery == null) {
      return showMessage(
        'Kiểm tra lại thông tin',
        'Mẹ chọn ngày sinh em bé nhé.',
      );
    }
    setState(() => saving = true);
    try {
      await client.dio.put(
        ApiConfig.profile,
        data: {
          'stage': stage,
          'height': h,
          'weight': w,
          'avgCycleLength': stage == 0 ? int.parse(cycle.text) : null,
          'lastPeriodDate': stage == 2 ? null : lmp?.toUtc().toIso8601String(),
          'deliveryDate': stage == 2
              ? delivery?.toUtc().toIso8601String()
              : null,
          'isBreastfeeding': stage == 2 ? breastfeeding : false,
        },
      );
      if (!mounted) return;
      await showMessage('Đã lưu', 'Hồ sơ sức khỏe của mẹ đã được cập nhật.');
      if (mounted) Navigator.pop(context);
    } catch (exception) {
      await showMessage('Chưa lưu được', exception.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> showMessage(String title, String message) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message.replaceFirst('Exception: ', '')),
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
      return const _Page(
        title: 'Hồ sơ của mẹ',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return _Page(
        title: 'Hồ sơ của mẹ',
        body: Center(
          child: TextButton(onPressed: load, child: const Text('Thử lại')),
        ),
      );
    }
    return _Page(
      title: 'Hồ sơ của mẹ',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Giai đoạn hiện tại', style: _heading),
          const SizedBox(height: 10),
          ...[
            ('Chuẩn bị mang thai', 'Theo dõi chu kỳ & ngày rụng trứng'),
            ('Đang mang thai', 'Theo dõi tuần thai & sự phát triển của bé'),
            ('Sau sinh & nuôi con', 'Hồi phục sức khỏe mẹ & chăm bé'),
          ].asMap().entries.map(
            (entry) => ListTile(
              onTap: () => setState(() => stage = entry.key),
              leading: Icon(
                entry.key == stage
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: entry.key == stage
                    ? AppColors.primaryDark
                    : AppColors.muted,
              ),
              title: Text(entry.value.$1),
              subtitle: Text(entry.value.$2),
            ),
          ),
          const SizedBox(height: 12),
          if (stage == 0) ...[
            _dateButton(
              'Ngày đầu kỳ kinh gần nhất',
              lmp,
              () => pickDate(false),
            ),
            _field(
              'Độ dài chu kỳ trung bình (ngày)',
              cycle,
              TextInputType.number,
            ),
          ] else if (stage == 1)
            _dateButton(
              'Ngày đầu kỳ kinh cuối (LMP)',
              lmp,
              () => pickDate(false),
            )
          else ...[
            _dateButton('Ngày sinh em bé', delivery, () => pickDate(true)),
            SwitchListTile(
              title: const Text('Mẹ đang nuôi con bằng sữa mẹ'),
              value: breastfeeding,
              onChanged: (value) => setState(() => breastfeeding = value),
            ),
          ],
          const Text('Chỉ số cơ thể', style: _heading),
          _field(
            'Chiều cao (cm)',
            height,
            const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(
            'Cân nặng (kg)',
            weight,
            const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: saving ? null : save,
            child: saving
                ? const CircularProgressIndicator()
                : const Text('Lưu hồ sơ'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
      ),
    ),
  );

  Widget _dateButton(String label, DateTime? value, VoidCallback onTap) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(
          value == null
              ? 'Chạm để chọn ngày'
              : '${value.day}/${value.month}/${value.year}',
        ),
        trailing: const Icon(LucideIcons.calendar),
        onTap: onTap,
      );

  static int _stage(Object? value) => value == 1 || value == 'Pregnant'
      ? 1
      : value == 2 || value == 'Postpartum'
      ? 2
      : 0;
  static String _text(Object? value) => value?.toString() ?? '';
  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.body});
  final String title;
  final Widget body;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(title: Text(title), backgroundColor: AppColors.cream),
    body: body,
  );
}

const _heading = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: AppColors.charcoal,
);
