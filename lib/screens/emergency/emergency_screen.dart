import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';
import 'package:momo_baby_healthcare_flutter/repositories/emergency/emergency_repository.dart';

const _places = [
  (label: 'Bệnh viện', query: 'bệnh viện', icon: LucideIcons.hospital),
  (
    label: 'BV Phụ sản',
    query: 'bệnh viện phụ sản',
    icon: LucideIcons.heartPulse,
  ),
  // Không dùng "bệnh viện nhi": trùng đúng tên một bệnh viện ở Hà Nội nên
  // Google Maps nhảy thẳng tới đó thay vì tìm quanh vị trí của mẹ.
  (label: 'BV Nhi', query: 'bệnh viện nhi khoa', icon: LucideIcons.baby),
  (label: 'Trạm y tế', query: 'trạm y tế', icon: LucideIcons.cross),
  (label: 'Nhà thuốc', query: 'nhà thuốc', icon: LucideIcons.pill),
];

/// (14) Khẩn cấp — nội dung theo panel "Khẩn cấp" của app Mobile, thêm định
/// vị GPS, tìm cơ sở y tế gần nhất và ghi sự kiện lên backend.
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  Position? position;
  String? locationError;
  bool locating = false;
  bool? reported;
  bool sendingSignal = false;
  List<EmergencyEvent>? events;
  String? historyError;

  @override
  void initState() {
    super.initState();
    locate();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final list = await EmergencyRepository.history();
      if (mounted) {
        setState(() {
          events = list;
          historyError = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => historyError = ApiError.getErrorMessage(e));
    }
  }

  Future<void> locate() async {
    setState(() {
      locating = true;
      locationError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const _LocationIssue(
          'GPS đang tắt. Mẹ bật Vị trí trên điện thoại rồi thử lại nhé.',
          open: Geolocator.openLocationSettings,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const _LocationIssue('Mẹ chưa cho phép Mom Ơi dùng vị trí.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw const _LocationIssue(
          'Quyền vị trí đang bị chặn. Mẹ mở Cài đặt để cho phép nhé.',
          open: Geolocator.openAppSettings,
        );
      }
      // Hiện nhanh vị trí gần nhất, rồi cập nhật vị trí chính xác.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) setState(() => position = last);
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (mounted) setState(() => position = current);
    } on _LocationIssue catch (issue) {
      if (!mounted) return;
      setState(() => locationError = issue.message);
      final open = issue.open;
      if (open != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(issue.message),
            action: SnackBarAction(label: 'Mở cài đặt', onPressed: open),
          ),
        );
      }
    } catch (_) {
      if (mounted && position == null) {
        setState(
          () => locationError =
              'Chưa lấy được vị trí. Mẹ ra chỗ thoáng hoặc thử lại nhé.',
        );
      }
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  String? get _coords {
    final p = position;
    if (p == null) return null;
    return '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';
  }

  String? get _mapsLink =>
      _coords == null ? null : 'https://maps.google.com/?q=$_coords';

  String get _helpMessage => _mapsLink == null
      ? 'Tôi cần hỗ trợ y tế khẩn cấp.'
      : 'Tôi cần hỗ trợ y tế khẩn cấp. Vị trí của tôi: $_mapsLink';

  Future<void> _open(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được ứng dụng phù hợp.')),
      );
    }
  }

  Future<void> call115() async {
    final coords = _coords;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(LucideIcons.phoneCall, color: MomTheme.emergency),
        title: const Text('Gọi cấp cứu 115?'),
        content: Text(
          coords == null
              ? 'Mẹ nói rõ địa chỉ và tình trạng của mẹ/bé cho tổng đài viên.'
              : 'Mẹ đọc vị trí này cho tổng đài viên:\n$coords',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MomTheme.emergency),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gọi 115'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    // Mở cuộc gọi ngay, ghi nhận lên backend chạy song song.
    _report();
    await _open(Uri(scheme: 'tel', path: '115'));
  }

  String get _nowHhmm {
    final now = TimeOfDay.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String get _where => _mapsLink == null ? '' : ' Vị trí: $_mapsLink';

  Future<void> _report() async {
    try {
      await EmergencyRepository.report('Mẹ đã gọi cấp cứu 115 lúc $_nowHhmm.$_where');
      if (mounted) setState(() => reported = true);
      loadHistory();
    } catch (e) {
      debugPrint('Không ghi được sự kiện khẩn cấp: ${ApiError.getErrorMessage(e)}');
      if (mounted) setState(() => reported = false);
    }
  }

  /// Ghi nhận sự cố (kèm vị trí) vào lịch sử khẩn cấp mà không gọi 115, để
  /// mẹ có mốc thời gian kể lại cho bác sĩ khi đi khám.
  Future<void> sendSignal() async {
    setState(() => sendingSignal = true);
    try {
      await EmergencyRepository.report(
        'Mẹ ghi nhận dấu hiệu cần hỗ trợ y tế lúc $_nowHhmm.$_where',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã ghi nhận vào lịch sử khẩn cấp.')),
      );
      await loadHistory();
    } catch (e) {
      if (mounted) {
        await showMomAlert(context, 'Chưa ghi nhận được', ApiError.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => sendingSignal = false);
    }
  }

  Future<void> resolve(EmergencyEvent event) async {
    try {
      await EmergencyRepository.resolve(event.id);
      await loadHistory();
    } catch (e) {
      if (mounted) {
        await showMomAlert(context, 'Chưa cập nhật được', ApiError.getErrorMessage(e));
      }
    }
  }

  /// App Google Maps bỏ qua phần `@lat,lng` của link web và tìm theo tên, nên
  /// "bệnh viện nhi" ra đúng chỗ tên "Bệnh Viện Nhi" ở Hà Nội. Trên Android
  /// dùng `geo:lat,lng?q=` để Maps tìm quanh vị trí của mẹ; nơi khác (hoặc
  /// khi máy không mở được `geo:`) dùng link tìm kiếm có kèm toạ độ.
  Future<void> findNearby(String query) async {
    final p = position;
    if (p != null &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      final geo = Uri.parse(
        'geo:${p.latitude},${p.longitude}?q=${Uri.encodeComponent(query)}',
      );
      if (await launchUrl(geo, mode: LaunchMode.externalApplication)) return;
    }
    return _open(
      Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': p == null
            ? '$query gần tôi'
            : '$query gần ${p.latitude},${p.longitude}',
      }),
    );
  }

  Future<void> copyLocation() async {
    await Clipboard.setData(ClipboardData(text: _helpMessage));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vị trí. Mẹ dán gửi người thân nhé.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MomScreen(
    eyebrow: 'Tiện ích & an toàn',
    title: 'Khẩn cấp',
    subtitle: 'Khi có dấu hiệu nguy hiểm, đừng chờ theo dõi tại nhà.',
    children: [
      MomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MomWarning(
              'Nếu đau nhiều, ra máu, sốt cao, khó thở hoặc thai máy giảm rõ '
              'rệt, hãy đến cơ sở y tế ngay.',
            ),
            const MomWarning(
              'Với bé: bỏ bú, tím tái, co giật, sốt cao kéo dài hoặc li bì là '
              'dấu hiệu cần khám ngay.',
            ),
            const SizedBox(height: 6),
            MomPrimaryButton(
              label: 'Gọi cấp cứu 115',
              icon: LucideIcons.phoneCall,
              color: MomTheme.emergency,
              onPressed: call115,
            ),
            const SizedBox(height: 8),
            MomSecondaryButton(
              label: sendingSignal
                  ? 'Đang ghi nhận…'
                  : 'Ghi nhận sự cố (không gọi)',
              icon: LucideIcons.bellRing,
              onPressed: sendingSignal ? null : sendSignal,
            ),
            if (reported != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  reported!
                      ? 'Đã ghi nhận cuộc gọi khẩn cấp vào mục Thông báo.'
                      : 'Chưa gửi được ghi nhận lên máy chủ (cuộc gọi vẫn được thực hiện).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: MomTheme.muted),
                ),
              ),
          ],
        ),
      ),
      const MomSectionTitle(
        title: 'Vị trí GPS của mẹ',
        subtitle: 'Đọc cho tổng đài viên hoặc gửi người thân',
      ),
      MomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: MomTheme.dangerLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.mapPin,
                    size: 18,
                    color: MomTheme.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _coords != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              _coords!,
                              style: const TextStyle(
                                color: MomTheme.charcoal,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (position != null)
                              Text(
                                'Sai số khoảng ${position!.accuracy.round()} m',
                                style: const TextStyle(
                                  color: MomTheme.mutedLight,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        )
                      : Text(
                          locationError ??
                              (locating
                                  ? 'Đang xác định vị trí…'
                                  : 'Chưa có vị trí.'),
                          style: TextStyle(
                            color: locationError != null
                                ? MomTheme.danger
                                : MomTheme.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                if (locating)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MomTheme.roseDark,
                    ),
                  )
                else
                  IconButton(
                    tooltip: 'Định vị lại',
                    onPressed: locate,
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    color: MomTheme.roseDark,
                  ),
              ],
            ),
            if (_coords != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _LocationAction(
                    label: 'Bản đồ',
                    icon: LucideIcons.map,
                    onTap: () => _open(Uri.parse(_mapsLink!)),
                  ),
                  const SizedBox(width: 8),
                  _LocationAction(
                    label: 'Sao chép',
                    icon: LucideIcons.copy,
                    onTap: copyLocation,
                  ),
                  const SizedBox(width: 8),
                  _LocationAction(
                    label: 'SMS',
                    icon: LucideIcons.messageSquare,
                    onTap: () => _open(
                      Uri(
                        scheme: 'sms',
                        queryParameters: {'body': _helpMessage},
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      const MomSectionTitle(
        title: 'Tìm cơ sở y tế gần mẹ',
        subtitle: 'Mở Google Maps quanh vị trí hiện tại',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _places
            .map(
              (p) => MomChip(
                label: p.label,
                icon: p.icon,
                iconColor: MomTheme.danger,
                onTap: () => findNearby(p.query),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 18),
      const _SignsCard(),
      MomSectionTitle(
        title: 'Lịch sử khẩn cấp',
        subtitle: 'Đã lưu trên hệ thống, xem lại được trong Thông báo',
        right: IconButton(
          tooltip: 'Tải lại',
          onPressed: loadHistory,
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          color: MomTheme.roseDark,
        ),
      ),
      _History(
        events: events,
        error: historyError,
        onResolve: resolve,
        onOpenMap: (url) => _open(Uri.parse(url)),
        onShowAll: showAllHistory,
      ),
    ],
  );

  /// Toàn bộ lịch sử trong bottom sheet cuộn riêng, để màn chính không dài
  /// thêm khi số lần khẩn cấp tăng lên.
  Future<void> showAllHistory() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MomTheme.cream,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
    ),
    builder: (_) => _HistorySheet(
      read: () => events ?? const [],
      onResolve: resolve,
      onOpenMap: (url) => _open(Uri.parse(url)),
    ),
  );
}

/// "Dấu hiệu cần đi khám ngay": thu gọn mặc định vì 2 cảnh báo chính đã nằm
/// ở đầu màn; mẹ chạm để xem đầy đủ.
class _SignsCard extends StatelessWidget {
  const _SignsCard();

  @override
  Widget build(BuildContext context) => MomCard(
    padding: EdgeInsets.zero,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: const ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: MomTheme.roseDark,
        collapsedIconColor: MomTheme.muted,
        leading: Icon(LucideIcons.stethoscope, size: 20, color: MomTheme.danger),
        title: Text(
          'Dấu hiệu cần đi khám ngay',
          style: TextStyle(
            color: MomTheme.charcoal,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text('Chạm để xem dấu hiệu ở mẹ và bé', style: MomText.muted),
        children: [
          Text('Ở mẹ', style: MomText.label),
          SizedBox(height: 6),
          _Bullet('Đau bụng dữ dội, ra máu hoặc ra nước âm đạo bất thường'),
          _Bullet('Đau đầu dữ dội, mờ mắt, phù mặt và tay'),
          _Bullet('Co giật, ngất xỉu, khó thở, đau ngực'),
          SizedBox(height: 10),
          Text('Ở bé', style: MomText.label),
          SizedBox(height: 6),
          _Bullet('Thở nhanh, rút lõm lồng ngực, tím tái'),
          _Bullet('Sốt từ 38°C ở bé dưới 3 tháng tuổi'),
          _Bullet('Vàng da lan xuống tay chân, li bì khó đánh thức'),
        ],
      ),
    ),
  );
}

class _LocationIssue implements Exception {
  const _LocationIssue(this.message, {this.open});

  final String message;
  final Future<bool> Function()? open;
}

/// Nút nhỏ icon trên, chữ dưới: 3 nút luôn nằm gọn một hàng, không xuống dòng.
class _LocationAction extends StatelessWidget {
  const _LocationAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: MomTheme.pinkLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
        side: const BorderSide(color: MomTheme.pink),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.control),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 18, color: MomTheme.roseDeep),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MomTheme.roseDeep,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text('•  $text', style: MomText.body),
  );
}

/// Số lần khẩn cấp hiện ngay trên màn chính; phần còn lại xem trong sheet.
const _previewCount = 2;

final _mapUrlPattern = RegExp(r'https?://\S+');

/// Lần chưa xử lý lên trước, sau đó mới nhất trước.
List<EmergencyEvent> _sorted(List<EmergencyEvent> events) => [...events]
  ..sort((a, b) {
    if (a.resolved != b.resolved) return a.resolved ? 1 : -1;
    final at = a.createdAt, bt = b.createdAt;
    if (at == null || bt == null) return 0;
    return bt.compareTo(at);
  });

class _History extends StatelessWidget {
  const _History({
    required this.events,
    required this.error,
    required this.onResolve,
    required this.onOpenMap,
    required this.onShowAll,
  });

  final List<EmergencyEvent>? events;
  final String? error;
  final Future<void> Function(EmergencyEvent) onResolve;
  final ValueChanged<String> onOpenMap;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final list = events;
    if (list == null) {
      return MomCard(
        child: Text(
          error ?? 'Đang tải…',
          style: TextStyle(
            fontSize: 13,
            color: error != null ? MomTheme.danger : MomTheme.muted,
          ),
        ),
      );
    }
    if (list.isEmpty) {
      return const MomCard(
        child: Text(
          'Chưa có lần khẩn cấp nào. Mong mẹ và bé luôn bình an 🌸',
          style: MomText.muted,
        ),
      );
    }
    final sorted = _sorted(list);
    final open = list.where((e) => !e.resolved).length;
    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            open > 0
                ? '${list.length} lần ghi nhận · $open lần chưa xác nhận an toàn'
                : '${list.length} lần ghi nhận · tất cả đã an toàn',
            style: MomText.muted,
          ),
          const SizedBox(height: 10),
          for (final (i, e) in sorted.take(_previewCount).indexed) ...[
            if (i > 0) const Divider(height: 20, color: MomTheme.borderSoft),
            _EventTile(
              event: e,
              compact: true,
              onResolve: () => onResolve(e),
              onOpenMap: onOpenMap,
            ),
          ],
          if (list.length > _previewCount) ...[
            const SizedBox(height: 12),
            MomSecondaryButton(
              label: 'Xem tất cả (${list.length})',
              icon: LucideIcons.history,
              onPressed: onShowAll,
            ),
          ],
        ],
      ),
    );
  }
}

/// Một lần khẩn cấp. Link Google Maps trong tin nhắn được tách ra thành nút
/// "Vị trí" thay vì in nguyên URL dài.
class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.onResolve,
    required this.onOpenMap,
    this.compact = false,
    this.resolving = false,
  });

  final EmergencyEvent event;
  final VoidCallback onResolve;
  final ValueChanged<String> onOpenMap;

  /// Màn chính: tối đa 2 dòng nội dung.
  final bool compact;
  final bool resolving;

  static String _time(DateTime? d) {
    if (d == null) return '';
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.hour)}:${p(d.minute)} · ${p(d.day)}/${p(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final raw = event.message.replaceFirst(emergencyMarker, '').trim();
    final mapUrl = _mapUrlPattern.firstMatch(raw)?.group(0);
    final text = raw
        .replaceAll(_mapUrlPattern, '')
        .replaceAll(RegExp(r'\s*Vị trí:\s*$'), '')
        .trim();
    final resolved = event.resolved;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          resolved ? LucideIcons.circleCheck : LucideIcons.siren,
          size: 18,
          color: resolved ? MomTheme.sageDark : MomTheme.danger,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: MomText.body,
                maxLines: compact ? 2 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
              ),
              const SizedBox(height: 2),
              Text(
                resolved
                    ? '${_time(event.createdAt)} · Đã an toàn'
                    : '${_time(event.createdAt)} · Chưa xác nhận',
                style: TextStyle(
                  fontSize: 12,
                  color: resolved ? MomTheme.mutedLight : MomTheme.danger,
                ),
              ),
              if (mapUrl != null || !resolved)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (mapUrl != null)
                        MomChip(
                          label: 'Vị trí',
                          icon: LucideIcons.mapPin,
                          iconColor: MomTheme.danger,
                          onTap: () => onOpenMap(mapUrl),
                        ),
                      if (!resolved)
                        MomChip(
                          label: resolving ? 'Đang lưu…' : 'Đã ổn',
                          icon: LucideIcons.check,
                          iconColor: MomTheme.sageDark,
                          onTap: resolving ? null : onResolve,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Toàn bộ lịch sử, cuộn trong sheet cao tối đa 85% màn hình.
class _HistorySheet extends StatefulWidget {
  const _HistorySheet({
    required this.read,
    required this.onResolve,
    required this.onOpenMap,
  });

  /// Đọc danh sách mới nhất từ màn cha (sau mỗi lần "Đã ổn" sẽ được tải lại).
  final List<EmergencyEvent> Function() read;
  final Future<void> Function(EmergencyEvent) onResolve;
  final ValueChanged<String> onOpenMap;

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  bool onlyOpen = false;
  int? resolvingId;

  Future<void> resolve(EmergencyEvent e) async {
    setState(() => resolvingId = e.id);
    await widget.onResolve(e);
    if (mounted) setState(() => resolvingId = null);
  }

  @override
  Widget build(BuildContext context) {
    final all = _sorted(widget.read());
    final open = all.where((e) => !e.resolved).length;
    final shown = onlyOpen ? all.where((e) => !e.resolved).toList() : all;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử khẩn cấp',
                  style: TextStyle(
                    color: MomTheme.charcoal,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    MomChip(
                      label: 'Tất cả (${all.length})',
                      selected: !onlyOpen,
                      onTap: () => setState(() => onlyOpen = false),
                    ),
                    MomChip(
                      label: 'Chưa xác nhận ($open)',
                      selected: onlyOpen,
                      onTap: () => setState(() => onlyOpen = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: shown.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Text(
                      'Không có lần nào chưa xác nhận an toàn 🌸',
                      style: MomText.muted,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 24, color: MomTheme.borderSoft),
                    itemBuilder: (_, i) {
                      final e = shown[i];
                      return _EventTile(
                        event: e,
                        resolving: resolvingId == e.id,
                        onResolve: () => resolve(e),
                        onOpenMap: widget.onOpenMap,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
