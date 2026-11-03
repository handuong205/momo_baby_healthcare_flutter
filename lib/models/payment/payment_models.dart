/// Trạng thái đơn. Backend trả enum dạng chuỗi; nhận cả dạng số cho chắc.
enum PaymentStatus { pending, completed, failed, refunded }

PaymentStatus parsePaymentStatus(Object? raw) {
  switch (raw?.toString().toLowerCase()) {
    case 'completed':
    case '1':
      return PaymentStatus.completed;
    case 'failed':
    case '2':
      return PaymentStatus.failed;
    case 'refunded':
    case '3':
      return PaymentStatus.refunded;
    default:
      return PaymentStatus.pending;
  }
}

/// `99000` -> `99.000 đ`
String formatVnd(num amount) {
  final digits = amount.round().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '$grouped đ';
}

/// Tên gói tiếng Việt, giống `getTierNameVi` bên web.
String tierNameVi(Object? tier) {
  switch (tier?.toString()) {
    case 'SuperMomVip':
    case '2':
      return 'Super Mom VIP';
    case 'MomHienDai':
    case '1':
      return 'Mẹ Hiện Đại';
    default:
      return 'Mẹ Bầu Cơ Bản';
  }
}

/// Gói trả phí, cùng mã gói và giá với `SubscriptionPlans` ở backend.
/// Số tiền phải trả thật luôn lấy từ đơn backend tạo ra ([PaymentOrder.amount]).
class PaidTier {
  final String id;
  final String name;
  final String subtitle;
  final int monthlyPrice;
  final int sixMonthPrice;
  final String monthlyPlanCode;
  final String sixMonthPlanCode;
  final List<String> features;

  const PaidTier({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.monthlyPrice,
    required this.sixMonthPrice,
    required this.monthlyPlanCode,
    required this.sixMonthPlanCode,
    required this.features,
  });

  int priceFor(int months) => months == 6 ? sixMonthPrice : monthlyPrice;

  String planCodeFor(int months) =>
      months == 6 ? sixMonthPlanCode : monthlyPlanCode;

  static const momHienDai = PaidTier(
    id: 'MomHienDai',
    name: 'Mẹ Hiện Đại',
    subtitle: 'Lựa chọn tối ưu cho mẹ',
    monthlyPrice: 99000,
    sixMonthPrice: 499000,
    monthlyPlanCode: 'HD_1M',
    sixMonthPlanCode: 'HD_6M',
    features: [
      'Mở khóa phác đồ IVF Timeline thông minh',
      'Gợi ý thực đơn dinh dưỡng 7 ngày',
      'Kế hoạch bài tập an toàn theo tam cá nguyệt',
      'Đánh giá nguy cơ trầm cảm sau sinh EPDS',
    ],
  );

  static const superMomVip = PaidTier(
    id: 'SuperMomVip',
    name: 'Super Mom VIP',
    subtitle: 'Đặc quyền chăm sóc toàn diện',
    monthlyPrice: 199000,
    sixMonthPrice: 999000,
    monthlyPlanCode: 'VIP_1M',
    sixMonthPlanCode: 'VIP_6M',
    features: [
      'Toàn bộ đặc quyền của gói Mẹ Hiện Đại',
      'Phân tích nhật ký cảm xúc và giọng nói AI',
      'Ưu tiên kết nối chuyên gia',
      'Care Staff đồng hành và phản hồi 24/7',
    ],
  );

  static const all = [momHienDai, superMomVip];
}

class BankInfo {
  final String bankName;
  final String bankShortName;
  final String accountNumber;
  final String accountName;

  const BankInfo({
    required this.bankName,
    required this.bankShortName,
    required this.accountNumber,
    required this.accountName,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      bankName: json['bankName']?.toString() ?? '',
      bankShortName: json['bankShortName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
    );
  }

  String get displayBank => bankName.isNotEmpty ? bankName : bankShortName;
}

/// Đơn chuyển khoản vừa tạo (`POST /api/payment/create`).
class PaymentOrder {
  final String orderCode;
  final String qrUrl;
  final num amount;
  final String planName;
  final String transferMemo;
  final BankInfo? bankInfo;

  const PaymentOrder({
    required this.orderCode,
    required this.qrUrl,
    required this.amount,
    required this.planName,
    required this.transferMemo,
    this.bankInfo,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    final qr = json['qrUrl']?.toString() ?? '';
    return PaymentOrder(
      orderCode: json['orderCode']?.toString() ?? '',
      qrUrl: qr.isNotEmpty ? qr : json['payUrl']?.toString() ?? '',
      amount: json['amount'] as num? ?? 0,
      planName: json['planName']?.toString() ?? '',
      transferMemo: json['transferMemo']?.toString() ?? '',
      bankInfo: json['bankInfo'] is Map
          ? BankInfo.fromJson(Map<String, dynamic>.from(json['bankInfo'] as Map))
          : null,
    );
  }
}

/// `GET /api/payment/status/{orderCode}`
class PaymentStatusInfo {
  final PaymentStatus status;
  final String? failureReason;

  const PaymentStatusInfo({required this.status, this.failureReason});

  factory PaymentStatusInfo.fromJson(Map<String, dynamic> json) {
    return PaymentStatusInfo(
      status: parsePaymentStatus(json['status']),
      failureReason: json['failureReason']?.toString(),
    );
  }
}

class PaymentTransaction {
  final String orderCode;
  final String planCode;
  final String tier;
  final int durationMonths;
  final num amount;
  final String paymentMethod;
  final PaymentStatus status;
  final DateTime? createdAt;
  final DateTime? paidAt;

  const PaymentTransaction({
    required this.orderCode,
    required this.planCode,
    required this.tier,
    required this.durationMonths,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
    this.paidAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) =>
        DateTime.tryParse(json[key]?.toString() ?? '')?.toLocal();
    return PaymentTransaction(
      orderCode: json['orderCode']?.toString() ?? '',
      planCode: json['planCode']?.toString() ?? '',
      tier: json['tier']?.toString() ?? '',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      amount: json['amount'] as num? ?? 0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      status: parsePaymentStatus(json['status']),
      createdAt: date('createdAt'),
      paidAt: date('paidAt'),
    );
  }
}

/// `GET /api/payment/history` — nguồn sự thật về gói hiện tại của mẹ.
class PaymentHistory {
  final String currentTier;
  final DateTime? tierExpiresAt;
  final List<PaymentTransaction> transactions;

  const PaymentHistory({
    required this.currentTier,
    this.tierExpiresAt,
    this.transactions = const [],
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      currentTier: json['currentTier']?.toString() ?? 'Free',
      tierExpiresAt: DateTime.tryParse(
        json['tierExpiresAt']?.toString() ?? '',
      )?.toLocal(),
      transactions: (json['transactions'] as List? ?? [])
          .whereType<Map>()
          .map((e) => PaymentTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  bool isCurrent(String tierId) => currentTier == tierId;

  Iterable<PaymentTransaction> get _completed =>
      transactions.where((t) => t.status == PaymentStatus.completed);

  int get completedCount => _completed.length;

  num get totalPaid => _completed.fold<num>(0, (sum, t) => sum + t.amount);

  int? daysLeft(DateTime now) {
    final expiry = tierExpiresAt;
    if (expiry == null) return null;
    final days = (expiry.difference(now).inMinutes / (24 * 60)).ceil();
    return days < 0 ? 0 : days;
  }
}
