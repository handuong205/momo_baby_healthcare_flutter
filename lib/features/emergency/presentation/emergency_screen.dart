import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_error.dart';
import '../../../shared/widgets/mom_ui.dart';
import '../../auth/state/auth_controller.dart';
import '../data/emergency_repository.dart';

const _places = [
  (label: 'Bệnh viện', query: 'bệnh viện', icon: LucideIcons.hospital),
  (
    label: 'BV Phụ sản',
    query: 'bệnh viện phụ sản',
    icon: LucideIcons.heartPulse,
  ),
  (label: 'BV Nhi', query: 'bệnh viện nhi', icon: LucideIcons.baby),
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
  late final repository = EmergencyRepository(
    context.read<AuthController>().repository.client,
  );
  Position? position;
  String? locationError;
  bool locating = false;
  bool? reported;

  @override
  void initState() {
    super.initState();
    locate();
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

  Future<void> _report() async {
    final now = TimeOfDay.now();
    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final where = _mapsLink == null ? '' : ' Vị trí: $_mapsLink';
    try {
      await repository.report('🚨 Mẹ đã gọi cấp cứu 115 lúc $hhmm.$where');
      if (mounted) setState(() => reported = true);
    } catch (e) {
      debugPrint('Không ghi được sự kiện khẩn cấp: ${apiErrorMessage(e)}');
      if (mounted) setState(() => reported = false);
    }
  }

  Future<void> findNearby(String query) {
    final p = position;
    return _open(
      p == null
          ? Uri.https('www.google.com', '/maps/search/$query gần đây')
          : Uri.https(
              'www.google.com',
              '/maps/search/$query/@${p.latitude},${p.longitude},15z',
            ),
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
                  Expanded(
                    child: MomSecondaryButton(
                      label: 'Bản đồ',
                      icon: LucideIcons.map,
                      onPressed: () => _open(Uri.parse(_mapsLink!)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MomSecondaryButton(
                      label: 'Sao chép',
                      icon: LucideIcons.copy,
                      onPressed: copyLocation,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MomSecondaryButton(
                      label: 'SMS',
                      icon: LucideIcons.messageSquare,
                      onPressed: () => _open(
                        Uri(
                          scheme: 'sms',
                          queryParameters: {'body': _helpMessage},
                        ),
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
      const MomSectionTitle(title: 'Dấu hiệu cần đi khám ngay'),
      const MomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    ],
  );
}

class _LocationIssue implements Exception {
  const _LocationIssue(this.message, {this.open});

  final String message;
  final Future<bool> Function()? open;
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
