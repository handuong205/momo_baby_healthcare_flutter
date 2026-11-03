import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/models/notification/notification_alert.dart';
import 'package:momo_baby_healthcare_flutter/repositories/notification/notification_repository.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

const _typeLabels = {
  'Symptom': 'Triệu chứng',
  'Medication': 'Uống thuốc',
  'RoutineCheck': 'Nhắc định kỳ',
};

/// Màn Thông báo, port từ `NotificationsScreen.tsx` bên RN.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationAlert>? _alerts;
  String? _error;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final alerts = await NotificationRepository.list();
      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = ApiError.getErrorMessage(e));
    }
  }

  Future<void> _resolve(NotificationAlert alert) async {
    setState(() => _busyId = alert.id);
    try {
      await NotificationRepository.markResolved(alert.id);
      if (!mounted) return;
      setState(() {
        _alerts = _alerts
            ?.map((a) => a.id == alert.id ? a.resolved() : a)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        await showMomAlert(
          context,
          'Chưa cập nhật được',
          ApiError.getErrorMessage(e),
        );
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  String? get _subtitle {
    final alerts = _alerts;
    if (alerts == null || alerts.isEmpty) return null;
    final pending = alerts.where((a) => !a.isResolved).length;
    return pending > 0
        ? 'Mẹ có $pending thông báo chưa xử lý.'
        : 'Mẹ đã xem hết các thông báo.';
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _alerts;
    return MomScreen(
      eyebrow: 'Cảnh báo & nhắc nhở',
      title: 'Thông báo',
      subtitle: _subtitle,
      onRefresh: _load,
      children: [
        if (_error != null)
          MomStateCard.error(_error!, onRetry: _load)
        else if (alerts == null)
          const MomLoadingView()
        else if (alerts.isEmpty)
          const MomStateCard(
            emoji: '🔔',
            title: 'Chưa có thông báo nào',
            body:
                'Cảnh báo sức khỏe, nhắc uống thuốc và lời khuyên từ chuyên gia sẽ hiện ở đây.',
          )
        else
          for (final alert in alerts)
            _AlertItem(
              alert: alert,
              busy: _busyId == alert.id,
              onResolve: () => _resolve(alert),
            ),
      ],
    );
  }
}

class _SeverityStyle {
  final Color color;
  final Color background;
  final String label;

  const _SeverityStyle(this.color, this.background, this.label);

  factory _SeverityStyle.of(String severity) => switch (severity) {
    'Critical' || 'High' => const _SeverityStyle(
      MomTheme.danger,
      MomTheme.dangerLight,
      'Quan trọng',
    ),
    'Medium' || 'Warning' => const _SeverityStyle(
      MomTheme.amberDark,
      MomTheme.amberLight,
      'Cần chú ý',
    ),
    'Positive' => const _SeverityStyle(
      MomTheme.sageDark,
      MomTheme.sageLight,
      'Tích cực',
    ),
    _ => const _SeverityStyle(MomTheme.blue, Color(0xFFEEF5FA), 'Thông tin'),
  };
}

class _AlertItem extends StatelessWidget {
  final NotificationAlert alert;
  final bool busy;
  final VoidCallback onResolve;

  const _AlertItem({
    required this.alert,
    required this.busy,
    required this.onResolve,
  });

  static String _formatDateTime(DateTime? value) {
    if (value == null) return '';
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(value.hour)}:${pad(value.minute)} '
        '${pad(value.day)}/${pad(value.month)}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final style = _SeverityStyle.of(alert.severity);
    return Opacity(
      opacity: alert.isResolved ? 0.65 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MomTheme.white,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: MomTheme.borderSoft),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.background,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.bellRing, size: 18, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          style.label,
                          style: TextStyle(
                            color: style.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        _typeLabels[alert.type] ?? alert.type,
                        style: const TextStyle(
                          color: MomTheme.mutedLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      color: MomTheme.charcoal,
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDateTime(alert.createdAt),
                          style: const TextStyle(
                            color: MomTheme.mutedLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (alert.isResolved)
                        const Text(
                          'Đã xử lý',
                          style: TextStyle(
                            color: MomTheme.sageDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: busy ? null : onResolve,
                          style: TextButton.styleFrom(
                            foregroundColor: MomTheme.roseDark,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(LucideIcons.checkCheck, size: 14),
                          label: const Text(
                            'Đã xem',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
