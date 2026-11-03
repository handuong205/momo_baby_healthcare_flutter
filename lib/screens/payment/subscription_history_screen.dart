import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/payment/payment_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/payment/payment_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/ai_ui.dart';

/// Lịch sử gói & giao dịch, tương ứng trang /subscription-history bên web.
class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  PaymentHistory? _history;
  bool _loading = true;
  String? _error;

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
      final history = await PaymentRepository.getHistory();
      if (mounted) setState(() => _history = history);
    } catch (e) {
      if (mounted) setState(() => _error = aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _history;
    return Scaffold(
      backgroundColor: MomTheme.cream,
      appBar: AppBar(
        backgroundColor: MomTheme.cream,
        title: const Text('Lịch sử gói', style: AiText.section),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: MomTheme.roseDark,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (_error != null) ...[
                AiErrorBox(message: _error!, onRetry: _load),
                const SizedBox(height: 14),
              ],
              if (_loading && h == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: MomTheme.roseDark),
                  ),
                ),
              if (h != null) ...[
                _Summary(history: h),
                const SizedBox(height: 20),
                const Text('Giao dịch gần đây', style: AiText.section),
                const SizedBox(height: 10),
                if (h.transactions.isEmpty)
                  const AiCard(
                    child: Text('Chưa có giao dịch nào.', style: AiText.muted),
                  )
                else
                  for (final txn in h.transactions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TransactionTile(txn: txn),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final PaymentHistory history;

  const _Summary({required this.history});

  @override
  Widget build(BuildContext context) {
    final expiry = history.tierExpiresAt;
    final days = history.daysLeft(DateTime.now());
    return AiCard(
      child: Column(
        children: [
          _SummaryRow(
            label: 'Gói hiện tại',
            value: tierNameVi(history.currentTier),
            color: MomTheme.roseDark,
          ),
          _SummaryRow(
            label: 'Hết hạn',
            value: expiry == null ? 'Chưa có' : formatViDate(expiry),
          ),
          _SummaryRow(
            label: 'Thời gian còn lại',
            value: days == null ? 'Chưa có hạn' : '$days ngày',
            color: MomTheme.amberDark,
          ),
          _SummaryRow(
            label: 'Đã thanh toán',
            value:
                '${formatVnd(history.totalPaid)} (${history.completedCount} giao dịch)',
            color: MomTheme.sageDark,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color = MomTheme.charcoal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AiText.muted)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AiText.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final PaymentTransaction txn;

  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (txn.status) {
      PaymentStatus.completed => (
        'Hoàn tất',
        MomTheme.sageDark,
        MomTheme.sageLight,
      ),
      PaymentStatus.pending => (
        'Chờ thanh toán',
        MomTheme.amberDark,
        AppColors.amberLight,
      ),
      PaymentStatus.failed => ('Thất bại', AppColors.rose, AppColors.roseLight),
      PaymentStatus.refunded => (
        'Đã hoàn tiền',
        MomTheme.muted,
        MomTheme.cream2,
      ),
    };

    return AiCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${tierNameVi(txn.tier)} · ${txn.durationMonths} tháng',
                  style: AiText.label,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(formatVnd(txn.amount), style: AiText.section),
          const SizedBox(height: 4),
          SelectableText('Mã đơn: ${txn.orderCode}', style: AiText.muted),
          Text(
            formatViDate(txn.paidAt ?? txn.createdAt),
            style: AiText.muted,
          ),
        ],
      ),
    );
  }
}
