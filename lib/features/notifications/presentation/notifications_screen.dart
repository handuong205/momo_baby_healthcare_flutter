import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/state/auth_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> alerts = [];
  bool loading = true;
  String? error;
  int? busy;
  ApiClient get client => context.read<AuthController>().repository.client;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await client.dio.get(ApiConfig.alerts);
      final data = (response.data as Map<String, dynamic>)['data'];
      setState(() {
        alerts = data is List
            ? data.whereType<Map<String, dynamic>>().toList()
            : [];
        loading = false;
      });
    } catch (exception) {
      setState(() {
        error = exception.toString();
        loading = false;
      });
    }
  }

  Future<void> resolve(int id) async {
    setState(() => busy = id);
    try {
      await client.dio.patch(
        ApiConfig.alertStatus(id),
        data: {'status': 'Resolved'},
      );
      setState(() {
        alerts = alerts
            .map((a) => a['id'] == id ? {...a, 'status': 'Resolved'} : a)
            .toList();
        busy = null;
      });
    } catch (_) {
      if (mounted) setState(() => busy = null);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(
      title: const Text('Thông báo'),
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
          : error != null
          ? ListView(
              children: [
                const SizedBox(height: 220),
                Center(child: Text('Không tải được thông báo')),
                Center(
                  child: TextButton(
                    onPressed: load,
                    child: const Text('Thử lại'),
                  ),
                ),
              ],
            )
          : alerts.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 220),
                Center(child: Icon(LucideIcons.bell, size: 42)),
                const Center(child: Text('Chưa có thông báo nào')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (_, index) {
                final alert = alerts[index];
                final open = alert['status'] != 'Resolved';
                return Card(
                  color: AppColors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(LucideIcons.bellRing),
                    ),
                    title: Text(alert['message']?.toString() ?? ''),
                    subtitle: Text(
                      '${alert['type'] ?? 'Thông tin'} · ${alert['severity'] ?? 'Info'}',
                    ),
                    trailing: open
                        ? TextButton(
                            onPressed: busy == alert['id']
                                ? null
                                : () => resolve(alert['id'] as int),
                            child: const Text('Đã xem'),
                          )
                        : const Text('Đã xử lý'),
                  ),
                );
              },
            ),
    ),
  );
}
