import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/state/auth_controller.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});
  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final name = TextEditingController(),
      dosage = TextEditingController(text: '1 viên'),
      notes = TextEditingController();
  List<Map<String, dynamic>> medications = [];
  bool loading = true, saving = false;
  ApiClient get client => context.read<AuthController>().repository.client;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    name.dispose();
    dosage.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final response = await client.dio.get(ApiConfig.medications);
      final data = (response.data as Map<String, dynamic>)['data'];
      setState(() {
        medications = data is List
            ? data.whereType<Map<String, dynamic>>().toList()
            : [];
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> add() async {
    if (name.text.trim().isEmpty || dosage.text.trim().isEmpty) {
      return message('Thiếu thông tin', 'Mẹ nhập tên thuốc và liều dùng nhé.');
    }
    setState(() => saving = true);
    try {
      await client.dio.post(
        ApiConfig.medications,
        data: {
          'medName': name.text.trim(),
          'dosage': dosage.text.trim(),
          'times': ['08:00'],
          'startDate': DateTime.now().toUtc().toIso8601String(),
          'endDate': DateTime.now()
              .add(const Duration(days: 30))
              .toUtc()
              .toIso8601String(),
          'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
        },
      );
      name.clear();
      notes.clear();
      await load();
    } catch (e) {
      await message('Chưa thêm được', e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> mark(int id, String status) async {
    await client.dio.post(
      ApiConfig.medicationAdherence(id),
      data: {
        'date': DateTime.now().toUtc().toIso8601String(),
        'status': status,
      },
    );
    await load();
  }

  Future<void> remove(int id) async {
    await client.dio.delete(ApiConfig.medicationById(id));
    await load();
  }

  Future<void> message(String title, String body) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(body.replaceFirst('Exception: ', '')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(
      title: const Text('Lịch uống thuốc'),
      backgroundColor: AppColors.cream,
    ),
    body: RefreshIndicator(
      onRefresh: load,
      child: loading
          ? ListView(
              children: const [
                SizedBox(height: 260),
                Center(child: CircularProgressIndicator()),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _input('Tên thuốc / vitamin', name, 'VD: Viên sắt'),
                        _input('Liều mỗi lần', dosage, 'VD: 1 viên'),
                        _input(
                          'Ghi chú (không bắt buộc)',
                          notes,
                          'VD: uống sau ăn sáng',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: saving ? null : add,
                            child: saving
                                ? const CircularProgressIndicator()
                                : const Text('Thêm thuốc / vitamin'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 18, bottom: 8),
                  child: Text(
                    'Đang theo dõi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                if (medications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Chưa có lịch uống thuốc')),
                  ),
                ...medications.map(
                  (med) => Card(
                    child: ListTile(
                      title: Text(med['medName']?.toString() ?? ''),
                      subtitle: Text(
                        '${med['dosage'] ?? ''} · ${(med['times'] as List?)?.join(', ') ?? ''}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            remove(med['id'] as int);
                          } else {
                            mark(med['id'] as int, value);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'taken', child: Text('Đã uống')),
                          PopupMenuItem(
                            value: 'skipped',
                            child: Text('Bỏ qua'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Xóa')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
  Widget _input(String label, TextEditingController controller, String hint) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            filled: true,
            fillColor: AppColors.cream,
          ),
        ),
      );
}
