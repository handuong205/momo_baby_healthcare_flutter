import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:momo_baby_healthcare_flutter/models/payment/payment_models.dart';
import 'package:momo_baby_healthcare_flutter/screens/payment/payment_screen.dart';

/// Dữ liệu mẫu theo đúng shape backend (`CreatePaymentResponseDto`, `GetHistoryAsync`).
void main() {
  group('Định dạng', () {
    test('formatVnd nhóm hàng nghìn bằng dấu chấm', () {
      expect(formatVnd(99000), '99.000 đ');
      expect(formatVnd(999000), '999.000 đ');
      expect(formatVnd(1298000), '1.298.000 đ');
      expect(formatVnd(0), '0 đ');
    });

    test('tierNameVi nhận cả chuỗi và số', () {
      expect(tierNameVi('SuperMomVip'), 'Super Mom VIP');
      expect(tierNameVi(1), 'Mẹ Hiện Đại');
      expect(tierNameVi('Free'), 'Mẹ Bầu Cơ Bản');
      expect(tierNameVi(null), 'Mẹ Bầu Cơ Bản');
    });
  });

  test('Mã gói và giá khớp SubscriptionPlans của backend', () {
    expect(PaidTier.momHienDai.planCodeFor(1), 'HD_1M');
    expect(PaidTier.momHienDai.planCodeFor(6), 'HD_6M');
    expect(PaidTier.superMomVip.planCodeFor(1), 'VIP_1M');
    expect(PaidTier.superMomVip.planCodeFor(6), 'VIP_6M');
    expect(PaidTier.momHienDai.priceFor(1), 99000);
    expect(PaidTier.momHienDai.priceFor(6), 499000);
    expect(PaidTier.superMomVip.priceFor(1), 199000);
    expect(PaidTier.superMomVip.priceFor(6), 999000);
  });

  test('parsePaymentStatus nhận chuỗi và số, mặc định là đang chờ', () {
    expect(parsePaymentStatus('Completed'), PaymentStatus.completed);
    expect(parsePaymentStatus(1), PaymentStatus.completed);
    expect(parsePaymentStatus('Failed'), PaymentStatus.failed);
    expect(parsePaymentStatus('Refunded'), PaymentStatus.refunded);
    expect(parsePaymentStatus('Pending'), PaymentStatus.pending);
    expect(parsePaymentStatus(null), PaymentStatus.pending);
  });

  test('PaymentOrder đọc đơn chuyển khoản', () {
    final order = PaymentOrder.fromJson({
      'orderCode': 'MO123',
      'payUrl': 'https://img.vietqr.io/a.png',
      'qrUrl': 'https://img.vietqr.io/a.png',
      'amount': 99000.0,
      'planName': 'Mom Hien Dai - 1 thang',
      'transferMemo': 'MOMOI MO123',
      'bankInfo': {
        'bankName': 'Ngan hang A',
        'bankShortName': 'A',
        'accountNumber': '0123',
        'accountName': 'CONG TY',
      },
    });

    expect(order.orderCode, 'MO123');
    expect(order.amount, 99000);
    expect(order.transferMemo, 'MOMOI MO123');
    expect(order.bankInfo!.displayBank, 'Ngan hang A');
    expect(order.bankInfo!.accountNumber, '0123');
  });

  test('PaymentOrder dùng payUrl khi thiếu qrUrl', () {
    final order = PaymentOrder.fromJson({'payUrl': 'https://x/qr.png', 'qrUrl': ''});
    expect(order.qrUrl, 'https://x/qr.png');
    expect(order.bankInfo, isNull);
  });

  group('PaymentHistory', () {
    final history = PaymentHistory.fromJson({
      'currentTier': 'MomHienDai',
      'tierExpiresAt': '2026-12-01T00:00:00Z',
      'transactions': [
        {
          'orderCode': 'A',
          'planCode': 'HD_1M',
          'tier': 'MomHienDai',
          'durationMonths': 1,
          'amount': 99000,
          'paymentMethod': 'BankTransfer',
          'status': 'Completed',
          'paidAt': '2026-11-01T00:00:00Z',
        },
        {
          'orderCode': 'B',
          'planCode': 'VIP_6M',
          'tier': 'SuperMomVip',
          'durationMonths': 6,
          'amount': 999000,
          'paymentMethod': 'BankTransfer',
          'status': 'Pending',
        },
      ],
    });

    test('chỉ cộng giao dịch đã hoàn tất', () {
      expect(history.transactions, hasLength(2));
      expect(history.completedCount, 1);
      expect(history.totalPaid, 99000);
      expect(history.isCurrent('MomHienDai'), isTrue);
    });

    test('daysLeft làm tròn lên và không âm', () {
      final expiry = history.tierExpiresAt!;
      expect(history.daysLeft(expiry.subtract(const Duration(hours: 25))), 2);
      expect(history.daysLeft(expiry.add(const Duration(days: 3))), 0);
      expect(
        const PaymentHistory(currentTier: 'Free').daysLeft(DateTime(2026)),
        isNull,
      );
    });
  });

  testWidgets('Đổi gói và chu kỳ cập nhật tổng tiền, chưa tạo đơn nào', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PaymentScreen(
          initialTier: PaidTier.momHienDai,
          currentTierName: 'Mẹ Bầu Cơ Bản',
        ),
      ),
    );

    expect(find.text('Tạo mã chuyển khoản'), findsOneWidget);
    expect(find.text('Quét mã VietQR'), findsNothing);
    expect(find.text('99.000 đ'), findsNWidgets(2)); // chu kỳ 1 tháng + tổng

    await tester.tap(find.text('6 tháng'));
    await tester.pump();
    expect(find.text('499.000 đ'), findsNWidgets(2));

    await tester.tap(find.text('Super Mom VIP'));
    await tester.pump();
    expect(find.text('999.000 đ'), findsNWidgets(2));
    expect(find.text('Tạo mã chuyển khoản'), findsOneWidget);
  });
}
