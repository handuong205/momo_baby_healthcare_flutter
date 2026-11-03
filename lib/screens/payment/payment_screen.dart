import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/payment/payment_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/payment/payment_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/ai_ui.dart';

/// Thanh toán chuyển khoản VietQR, cùng luồng với trang /payment bên web:
/// tạo đơn -> quét QR hoặc chép thông tin -> tự kiểm tra trạng thái mỗi 4 giây.
///
/// Trả về `true` qua Navigator khi gói đã kích hoạt.
class PaymentScreen extends StatefulWidget {
  final PaidTier initialTier;
  final String currentTierName;

  const PaymentScreen({
    super.key,
    required this.initialTier,
    required this.currentTierName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 4);

  late PaidTier _tier = widget.initialTier;
  int _months = 1;

  PaymentOrder? _order;
  PaymentStatus _status = PaymentStatus.pending;
  bool _creating = false;
  bool _checking = false;
  bool _pollInFlight = false;
  String? _error;
  Timer? _pollTimer;

  bool get _busy => _creating || _status == PaymentStatus.completed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Mẹ vừa quay lại từ app ngân hàng: kiểm tra ngay, không chờ đến nhịp sau.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(silent: true);
  }

  void _select({PaidTier? tier, int? months}) {
    // Đổi lựa chọn thì bỏ đơn đang hiện để mẹ không chuyển nhầm số tiền của đơn cũ.
    _pollTimer?.cancel();
    setState(() {
      _tier = tier ?? _tier;
      _months = months ?? _months;
      _order = null;
      _status = PaymentStatus.pending;
      _error = null;
    });
  }

  Future<void> _createOrder() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final order = await PaymentRepository.createBankTransfer(
        _tier.planCodeFor(_months),
      );
      if (!mounted) return;
      setState(() => _order = order);
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(_pollInterval, (_) => _check(silent: true));
    } catch (e) {
      if (mounted) setState(() => _error = aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _check({bool silent = false}) async {
    final order = _order;
    if (order == null ||
        _status != PaymentStatus.pending ||
        _pollInFlight) {
      return;
    }

    _pollInFlight = true;
    if (!silent) {
      setState(() {
        _checking = true;
        _error = null;
      });
    }

    try {
      final info = await PaymentRepository.getStatus(order.orderCode);
      // Mẹ đã đổi gói trong lúc chờ: kết quả này thuộc đơn cũ
      if (!mounted || !identical(order, _order)) return;

      switch (info.status) {
        case PaymentStatus.completed:
          await _onCompleted();
        case PaymentStatus.failed:
        case PaymentStatus.refunded:
          _pollTimer?.cancel();
          setState(() {
            _status = info.status;
            _error = info.failureReason ?? 'Giao dịch không thành công.';
          });
        case PaymentStatus.pending:
          if (!silent) {
            _snack(
              'Chưa ghi nhận thanh toán. Mẹ đợi thêm một lát hoặc kiểm tra lại nội dung chuyển khoản nhé.',
            );
          }
      }
    } catch (e) {
      // Lỗi mạng khi tự kiểm tra thì thử lại ở nhịp sau, không làm mẹ hoang mang
      if (!silent && mounted) setState(() => _error = aiErrorMessage(e));
    } finally {
      _pollInFlight = false;
      if (!silent && mounted) setState(() => _checking = false);
    }
  }

  Future<void> _onCompleted() async {
    _pollTimer?.cancel();
    setState(() => _status = PaymentStatus.completed);
    await PaymentRepository.refreshTierClaim();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    _snack('Đã chép $label');
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MomTheme.cream,
      appBar: AppBar(
        backgroundColor: MomTheme.cream,
        title: const Text('Thanh toán', style: AiText.section),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildPlanCard(),
            const SizedBox(height: 14),
            if (_error != null) ...[
              AiCard(
                color: AppColors.roseLight,
                borderColor: AppColors.rose.withValues(alpha: 0.35),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.rose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AiText.body.copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (_order == null) _buildCreateButton() else _buildOrder(_order!),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            icon: Icons.workspace_premium_rounded,
            title: 'Chọn gói dịch vụ',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, t) in PaidTier.all.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _OptionTile(
                    title: t.name,
                    subtitle: '${formatVnd(t.monthlyPrice)}/tháng',
                    selected: _tier.id == t.id,
                    onTap: _busy ? null : () => _select(tier: t),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Text('Chu kỳ thanh toán', style: AiText.label),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, m) in const [1, 6].indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _OptionTile(
                    title: '$m tháng',
                    subtitle: formatVnd(_tier.priceFor(m)),
                    selected: _months == m,
                    onTap: _busy ? null : () => _select(months: m),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 28, color: MomTheme.borderSoft),
          Text(
            'Gói hiện tại: ${widget.currentTierName}',
            style: AiText.muted,
          ),
          const SizedBox(height: 6),
          const Text('Tổng thanh toán', style: AiText.muted),
          Text(
            formatVnd(_order?.amount ?? _tier.priceFor(_months)),
            style: AiText.title.copyWith(color: MomTheme.roseDark, fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _creating ? null : _createOrder,
        icon: _creating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: MomTheme.white,
                ),
              )
            : const Icon(Icons.qr_code_2_rounded),
        label: Text(_creating ? 'Đang tạo đơn...' : 'Tạo mã chuyển khoản'),
        style: ElevatedButton.styleFrom(
          backgroundColor: MomTheme.roseDark,
          disabledBackgroundColor: MomTheme.beige,
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildOrder(PaymentOrder order) {
    final bank = order.bankInfo;
    final completed = _status == PaymentStatus.completed;
    final waiting = _status == PaymentStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Quét mã VietQR', style: AiText.section),
                  ),
                  _StatusBadge(status: _status),
                ],
              ),
              const SizedBox(height: 14),
              Center(child: _QrImage(url: order.qrUrl)),
              if (order.qrUrl.isNotEmpty)
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        launchExternal(context, Uri.parse(order.qrUrl)),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Mở ảnh QR để lưu về máy'),
                  ),
                ),
              const SizedBox(height: 4),
              const Text(
                'Đang dùng chính điện thoại này? Mẹ lưu ảnh QR rồi chọn ảnh trong app ngân hàng, hoặc chép thông tin bên dưới.',
                style: AiText.muted,
              ),
              const SizedBox(height: 12),
              if (bank != null) ...[
                _CopyRow(
                  label: 'Ngân hàng',
                  value: bank.displayBank,
                  onCopy: _copy,
                ),
                _CopyRow(
                  label: 'Số tài khoản',
                  value: bank.accountNumber,
                  onCopy: _copy,
                ),
                _CopyRow(
                  label: 'Chủ tài khoản',
                  value: bank.accountName,
                  onCopy: _copy,
                ),
              ],
              _CopyRow(
                label: 'Số tiền',
                value: formatVnd(order.amount),
                copyValue: order.amount.round().toString(),
                onCopy: _copy,
              ),
              _CopyRow(
                label: 'Nội dung',
                value: order.transferMemo,
                onCopy: _copy,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AiCard(
          color: AppColors.blueLight,
          borderColor: AppColors.blue.withValues(alpha: 0.25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mẹ chuyển đúng số tiền và giữ nguyên nội dung để hệ thống tự xác nhận.',
                  style: AiText.body.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: waiting && !_checking ? _check : null,
            icon: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: MomTheme.white,
                    ),
                  )
                : Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.task_alt_rounded,
                  ),
            label: Text(
              completed
                  ? 'Đã kích hoạt gói'
                  : _checking
                  ? 'Đang kiểm tra...'
                  : 'Tôi đã chuyển khoản xong',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: MomTheme.roseDark,
              disabledBackgroundColor: MomTheme.beige,
              textStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (!waiting && !completed) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _select(),
            child: const Text('Tạo đơn mới'),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MomTheme.pinkLight : MomTheme.creamSoft,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.control),
            border: Border.all(
              color: selected ? MomTheme.roseDark : MomTheme.beige,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AiText.label),
              const SizedBox(height: 2),
              Text(subtitle, style: AiText.muted.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status) {
      PaymentStatus.completed => (
        'Đã hoàn tất',
        MomTheme.sageDark,
        MomTheme.sageLight,
      ),
      PaymentStatus.pending => (
        'Chờ thanh toán',
        MomTheme.amberDark,
        AppColors.amberLight,
      ),
      _ => ('Không thành công', AppColors.rose, AppColors.roseLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }
}

class _QrImage extends StatelessWidget {
  final String url;

  const _QrImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: MomTheme.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: MomTheme.pink, width: 2),
      ),
      child: url.isEmpty
          ? const _QrUnavailable()
          : Image.network(
              url,
              fit: BoxFit.contain,
              semanticLabel: 'Mã VietQR thanh toán',
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(
                        color: MomTheme.roseDark,
                      ),
                    ),
              errorBuilder: (_, _, _) => const _QrUnavailable(),
            ),
    );
  }
}

class _QrUnavailable extends StatelessWidget {
  const _QrUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Không tải được mã QR. Mẹ dùng thông tin chuyển khoản bên dưới nhé.',
        textAlign: TextAlign.center,
        style: AiText.muted,
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final String? copyValue;
  final Future<void> Function(String value, String label) onCopy;

  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.copyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: MomTheme.creamSoft,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: MomTheme.borderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AiText.muted.copyWith(fontSize: 13)),
                SelectableText(
                  value.isEmpty ? 'Chưa cấu hình' : value,
                  style: AiText.label.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chép $label',
            onPressed: value.isEmpty
                ? null
                : () => onCopy(copyValue ?? value, label.toLowerCase()),
            icon: const Icon(Icons.copy_rounded, color: MomTheme.roseDark),
          ),
        ],
      ),
    );
  }
}
