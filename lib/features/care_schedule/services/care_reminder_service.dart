import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/care_schedule.dart';

/// Chuông nhắc cho lịch chăm sóc: thông báo hẹn giờ có âm thanh (loa)
/// và phát thử chuông ngay trong app.
class CareReminderService {
  CareReminderService._();

  static final instance = CareReminderService._();

  static const _channelId = 'care_schedule_alarm_v1';
  static const _channelName = 'Lịch chăm sóc';
  static const _chimeAsset = 'audio/care_chime.wav';
  static const payloadPrefix = 'care:';

  final _plugin = FlutterLocalNotificationsPlugin();
  final _chime = AudioPlayer(playerId: 'care_chime');
  bool _ready = false;

  /// Gọi khi mẹ chạm vào thông báo (vd. mở màn Lịch chăm sóc).
  void Function(String? payload)? onNotificationTap;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (_ready || !isSupported) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(_guessLocation());
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onNotificationTap?.call(response.payload),
    );
    _ready = true;
  }

  /// Mở app từ thông báo khi app đã bị tắt.
  Future<String?> launchPayload() async {
    if (!isSupported) return null;
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  /// Xin quyền thông báo (Android 13+, iOS). Trả về false nếu mẹ từ chối.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? true;
      if (await android.canScheduleExactNotifications() == false) {
        await android.requestExactAlarmsPermission();
      }
      return granted;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  /// Số ngày tới được đặt chuông trước; app đặt lại mỗi lần mở / tải lịch.
  static const _daysAhead = 7;

  /// Android giới hạn số báo thức mỗi app, nên giữ dưới mức này.
  static const _maxPending = 60;

  /// Đặt lại toàn bộ chuông theo lịch từ backend: mỗi giờ nhắc trong
  /// [_daysAhead] ngày tới, nằm trong khoảng ngày của lịch. Bỏ qua hôm nay nếu
  /// mẹ đã đánh dấu đã làm / bỏ qua.
  Future<void> sync(List<CareSchedule> schedules) async {
    if (!isSupported) return;
    await init();
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    final today = startOfToday();
    final mode = await _scheduleMode();
    final pending = <(tz.TZDateTime, CareSchedule)>[];
    for (final schedule in schedules) {
      for (var offset = 0; offset < _daysAhead; offset++) {
        final day = today.add(Duration(days: offset));
        if (!schedule.activeOn(day)) continue;
        if (offset == 0 && schedule.statusOn(day) != null) continue;
        for (final time in schedule.times) {
          final parts = time.split(':');
          final hour = int.tryParse(parts.first);
          final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;
          if (hour == null || minute == null) continue;
          final at = tz.TZDateTime(
            tz.local,
            day.year,
            day.month,
            day.day,
            hour,
            minute,
          );
          if (at.isAfter(now)) pending.add((at, schedule));
        }
      }
    }
    pending.sort((a, b) => a.$1.compareTo(b.$1));

    var id = 1;
    for (final (at, schedule) in pending.take(_maxPending)) {
      final hhmm =
          '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: mode,
        title: '${schedule.category.label} · $hhmm',
        body: schedule.notes == null
            ? schedule.meta.isEmpty
                  ? schedule.name
                  : '${schedule.name} (${schedule.meta})'
            : '${schedule.name} — ${schedule.notes}',
        payload: '$payloadPrefix${schedule.id}',
      );
    }
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    await init();
    await _plugin.cancelAll();
  }

  /// Phát thử chuông qua loa.
  Future<void> playChime() async {
    await _chime.stop();
    await _chime.play(AssetSource(_chimeAsset), volume: 1);
  }

  /// Bắn một thông báo ngay để mẹ kiểm tra chuông và quyền thông báo.
  Future<void> showTest() async {
    if (!isSupported) return playChime();
    await init();
    await _plugin.show(
      id: 0,
      title: 'Chuông nhắc Mom Ơi',
      body: 'Chuông đang hoạt động. Mom Ơi sẽ nhắc mẹ đúng giờ nhé!',
      notificationDetails: _details,
      payload: payloadPrefix,
    );
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final exact = await android?.canScheduleExactNotifications() ?? true;
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Chuông nhắc uống thuốc, cho bé bú, tiêm chủng…',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('care_chime'),
      enableVibration: true,
      ticker: 'Lịch chăm sóc',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  /// App dành cho người dùng Việt Nam; với múi giờ khác dùng UTC + offset
  /// cố định của máy để giờ nhắc vẫn khớp giờ địa phương.
  static tz.Location _guessLocation() {
    final offset = DateTime.now().timeZoneOffset;
    if (offset == const Duration(hours: 7)) {
      return tz.getLocation('Asia/Ho_Chi_Minh');
    }
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (location.currentTimeZone.offset == offset &&
          location.name.contains('/')) {
        return location;
      }
    }
    return tz.UTC;
  }
}
