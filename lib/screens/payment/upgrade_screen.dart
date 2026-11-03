import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/payment/payment_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/payment/payment_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/ai_ui.dart';
import 'package:momo_baby_healthcare_flutter/screens/payment/payment_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/payment/subscription_history_screen.dart';

/// Bảng gói dịch vụ, tương ứng trang /upgrade bên web.
///
/// Không có nút "Chuyển về gói cơ bản": backend chưa có API cho thao tác này.
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  static const _freeFeatures = [
    'Lịch rụng trứng và dự đoán chu kỳ',
    'Theo dõi cân nặng, chiều cao, BMI',
    'Sổ tay thai kỳ cơ bản theo tuần',
    'Nhắc lịch khám thai định kỳ',
    'Tra cứu thực phẩm an toàn',
  ];

  PaymentHistory? _history;
  bool _loading = true;
  String? _error;
  bool _justPaid = false;

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

  Future<void> _openPayment(PaidTier tier) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          initialTier: tier,
          currentTierName: tierNameVi(_history?.currentTier),
        ),
      ),
    );
    if (!mounted) return;
    if (paid == true) setState(() => _justPaid = true);
    // Luôn tải lại: mẹ có thể đã chuyển khoản rồi bấm quay lại
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final history = _history;
    return Scaffold(
      backgroundColor: MomTheme.cream,
      appBar: AppBar(
        backgroundColor: MomTheme.cream,
        title: const Text('Gói dịch vụ', style: AiText.section),
        actions: [
          IconButton(
            tooltip: 'Lịch sử gói',
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SubscriptionHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: MomTheme.roseDark,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (_justPaid && history != null) ...[
                _SuccessBanner(tierName: tierNameVi(history.currentTier)),
                const SizedBox(height: 14),
              ],
              if (_error != null) ...[
                AiErrorBox(message: _error!, onRetry: _load),
                const SizedBox(height: 14),
              ],
              _CurrentTierCard(history: history, loading: _loading),
              const SizedBox(height: 14),
              _TierCard(
                name: 'Mẹ Bầu Cơ Bản',
                subtitle: 'Trải nghiệm chăm sóc nền tảng',
                price: 'Miễn phí',
                features: _freeFeatures,
                isCurrent: history != null && _isFree(history),
              ),
              for (final tier in PaidTier.all) ...[
                const SizedBox(height: 14),
                _TierCard(
                  name: tier.name,
                  subtitle: tier.subtitle,
                  price: '${formatVnd(tier.monthlyPrice)} / tháng',
                  secondaryPrice: '${formatVnd(tier.sixMonthPrice)} / 6 tháng',
                  features: tier.features,
                  highlighted: true,
                  isCurrent: history?.isCurrent(tier.id) ?? false,
                  // Chưa biết gói hiện tại thì chưa cho thanh toán
                  onUpgrade: history == null ? null : () => _openPayment(tier),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isFree(PaymentHistory history) =>
      !PaidTier.all.any((t) => history.isCurrent(t.id));
}

class _SuccessBanner extends StatelessWidget {
  final String tierName;

  const _SuccessBanner({required this.tierName});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      color: MomTheme.sageLight,
      borderColor: MomTheme.sageMuted,
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded, color: MomTheme.sageDark, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thanh toán thành công', style: AiText.section),
                Text('Gói $tierName đã được kích hoạt.', style: AiText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentTierCard extends StatelessWidget {
  final PaymentHistory? history;
  final bool loading;

  const _CurrentTierCard({required this.history, required this.loading});

  @override
  Widget build(BuildContext context) {
    final h = history;
    final expiry = h?.tierExpiresAt;
    return AiCard(
      color: MomTheme.pinkLight,
      borderColor: MomTheme.pink,
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: MomTheme.roseDark,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gói hiện tại của mẹ', style: AiText.muted),
                Text(
                  h != null
                      ? tierNameVi(h.currentTier)
                      : (loading ? 'Đang tải...' : 'Chưa tải được'),
                  style: AiText.section,
                ),
                if (expiry != null)
                  Text(
                    'Hết hạn: ${formatViDate(expiry)}',
                    style: AiText.muted,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;
  final String? secondaryPrice;
  final List<String> features;
  final bool highlighted;
  final bool isCurrent;
  final VoidCallback? onUpgrade;

  const _TierCard({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.features,
    required this.isCurrent,
    this.secondaryPrice,
    this.highlighted = false,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return AiCard(
      borderColor: highlighted ? MomTheme.rose : MomTheme.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AiText.section),
                    Text(subtitle, style: AiText.muted),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: MomTheme.sageLight,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'Đang dùng',
                    style: AiText.muted.copyWith(
                      color: MomTheme.sageDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(price, style: AiText.title.copyWith(fontSize: 22)),
          if (secondaryPrice != null)
            Text(
              secondaryPrice!,
              style: AiText.label.copyWith(color: MomTheme.roseDark),
            ),
          AiBulletList(items: features),
          if (highlighted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isCurrent ? null : onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: MomTheme.beige,
                  textStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(isCurrent ? 'Gói hiện tại của mẹ' : 'Nâng cấp ngay'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
