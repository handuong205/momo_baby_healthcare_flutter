import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';
import 'package:momo_baby_healthcare_flutter/utils/kick_detector.dart';

/// Đếm cử động thai bằng cảm biến gia tốc: mẹ đặt điện thoại lên bụng rồi
/// bấm bắt đầu. Máy không có cảm biến (web/desktop) thì chuyển sang chạm tay.
class KickCounterCard extends StatefulWidget {
  const KickCounterCard({super.key});

  @override
  State<KickCounterCard> createState() => _KickCounterCardState();
}

class _KickCounterCardState extends State<KickCounterCard> {
  final _detector = KickDetector();
  StreamSubscription<AccelerometerEvent>? _subscription;

  int _count = 0;
  bool _running = false;
  bool _sensorUnsupported = false;

  bool get _canUseSensor =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _stop();
      return;
    }

    _detector.reset();
    if (!_canUseSensor) {
      setState(() {
        _running = true;
        _sensorUnsupported = true;
      });
      return;
    }

    try {
      _subscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen(
        (event) {
          if (_detector.addSample(event.x, event.y, event.z, DateTime.now())) {
            setState(() => _count++);
          }
        },
        onError: (Object _) => _fallbackToTap(),
        cancelOnError: true,
      );
      setState(() {
        _running = true;
        _sensorUnsupported = false;
      });
    } catch (_) {
      _fallbackToTap();
    }
  }

  void _fallbackToTap() {
    if (!mounted) return;
    setState(() {
      _sensorUnsupported = true;
      _running = true;
    });
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
    setState(() => _running = false);
  }

  void _reset() {
    _stop();
    setState(() => _count = 0);
  }

  void _addManual() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.baby, size: 17, color: MomTheme.roseDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Đếm cử động thai', style: MomText.label),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MomTheme.roseDark,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    color: MomTheme.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _sensorUnsupported
                ? 'Thiết bị này không có cảm biến gia tốc. Mẹ chạm vào ô bên dưới '
                      'mỗi khi bé đạp nhé.'
                : 'Đặt điện thoại lên bụng, bấm bắt đầu và giữ yên. App tự đếm '
                      'mỗi lần bé đạp. Cần đếm tay thì chạm vào ô số.',
            style: MomText.muted,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _addManual,
            child: Semantics(
              button: true,
              label: 'Thêm một cử động thai, hiện $_count',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _running ? MomTheme.pinkLight : MomTheme.cream2,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(
                    color: _running ? MomTheme.pink : MomTheme.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_count',
                      style: const TextStyle(
                        color: MomTheme.roseDeep,
                        fontSize: 34,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _running ? 'Đang đếm — chạm để cộng thêm' : 'Chạm để cộng thêm',
                      style: MomText.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MomPrimaryButton(
                  label: _running ? 'Dừng' : 'Bắt đầu',
                  icon: _running ? LucideIcons.pause : LucideIcons.play,
                  onPressed: _toggle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MomSecondaryButton(
                  label: 'Đặt lại',
                  icon: LucideIcons.rotateCcw,
                  onPressed: _count == 0 ? null : _reset,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Nếu bé máy ít hơn bình thường hoặc mẹ lo lắng, hãy liên hệ bác sĩ '
            'sản khoa để được kiểm tra.',
            style: MomText.muted,
          ),
        ],
      ),
    );
  }
}
