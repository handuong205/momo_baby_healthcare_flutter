import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/models/pregnancy/pregnancy_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/auth/auth_repository.dart';
import 'package:momo_baby_healthcare_flutter/repositories/dashboard/dashboard_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/auth/login_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/ovulation_calendar_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/journey_selection_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/epds_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/pregnancy_week_screen.dart';
import 'package:momo_baby_healthcare_flutter/services/token_service.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/app_header.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/celebration_overlay.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/reaction_picker.dart';

/// Màu riêng của trang chủ (RN: các mã màu viết thẳng trong DashboardScreen).
class _C {
  static const waterBg = Color(0xFFF0F6FB);
  static const waterIconBg = Color(0xFFDCEBFA);
  static const blue = MomTheme.blue; // #4A88C7
  static const sleepBg = Color(0xFFF6F2FB);
  static const sleepIconBg = Color(0xFFEADFF8);
  static const purple = MomTheme.purple; // #8E6BB8
  static const moodBg = Color(0xFFFCF2F4);
  static const moodIconBg = Color(0xFFF9DCE3);

  /// Nền tròn sau ảnh emoji tâm trạng (hồng nhạt).
  static const moodImageBg = MomTheme.pink; // #F2D0DC
  static const waterTrack = Color(0xFFEAE6DF);
  static const warmBg = Color(0xFFFFF8F0);
  static const warmBorder = Color(0xFFF7E7D0);
  static const warmIconBg = Color(0xFFFFE9D4);
}

/// RN: SHADOWS.sm và SHADOWS.card.
const List<BoxShadow> _shadowSm = [
  BoxShadow(color: Color(0x0A2C2118), offset: Offset(0, 2), blurRadius: 4),
];
const List<BoxShadow> _shadowCard = [
  BoxShadow(color: Color(0x0D2C2118), offset: Offset(0, 6), blurRadius: 14),
];

class _StageShortcut {
  final String title;
  final String sub;

  const _StageShortcut(this.title, this.sub);
}

const Map<int, _StageShortcut> _stageShortcut = {
  0: _StageShortcut('Chu kỳ & rụng trứng', 'Dự đoán ngày dễ thụ thai'),
  1: _StageShortcut('Theo dõi thai kỳ', 'Tuần thai & cân nặng mẹ'),
  2: _StageShortcut('Phục hồi sau sinh', 'Vận động & khảo sát EPDS'),
};

/// Tab "Tổng quan", port từ `DashboardScreen.tsx` bên React Native.
class HomeScreen extends StatefulWidget {
  /// Chuyển sang tab khác trong AppShell (1: Lộ trình, 2: Bé yêu, 3: AI).
  final ValueChanged<int>? onSelectTab;

  /// `true` khi tab Tổng quan đang hiển thị; mỗi lần quay lại thì tải lại.
  final bool isActive;

  const HomeScreen({super.key, this.onSelectTab, this.isActive = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  DashboardProfile? _profile;
  PregnancyWeekInfo? _weekInfo;
  int _waterCups = 0;
  int? _moodScore;
  num? _sleepHours;
  int _pendingAlerts = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _loadAll();
  }

  Future<void> _loadAll() async {
    final name = await TokenService.getUserName();
    final results = await Future.wait<Object?>([
      _settle<DashboardProfile?>(DashboardRepository.getProfile()),
      _settle<TodayMonitoring>(DashboardRepository.getTodayMonitoring()),
      _settle<int>(DashboardRepository.getPendingAlertCount()),
    ]);
    if (!mounted) return;

    final profile = results[0] as DashboardProfile?;
    final today = results[1] as TodayMonitoring?;
    final alerts = results[2] as int?;

    setState(() {
      _userName = name;
      _profile = profile;
      if (today != null) {
        _waterCups = today.waterCups;
        _moodScore = today.moodScore;
        _sleepHours = today.sleepHours;
      }
      if (alerts != null) _pendingAlerts = alerts;
    });

    if (profile != null && profile.stage == 1) {
      final info = await _settle(DashboardRepository.getPregnancyThisWeek());
      if (mounted) setState(() => _weekInfo = info);
    } else {
      setState(() => _weekInfo = null);
    }
  }

  /// Giống `Promise.allSettled`: lỗi một API không làm hỏng cả trang.
  Future<T?> _settle<T>(Future<T> future) async {
    try {
      return await future;
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      return null;
    }
  }

  Future<void> _addWater() async {
    if (_waterCups >= 20) {
      _showAlert('Tuyệt vời!', 'Mẹ đã uống rất nhiều nước hôm nay rồi.');
      return;
    }
    final next = _waterCups + 1;
    final reachedGoal = next == dailyCupGoal;
    setState(() => _waterCups = next);
    if (!reachedGoal) _rainWaterDrops();
    try {
      await DashboardRepository.saveDailyMonitoring({
        'waterLiters': next * litersPerCup,
      });
      // Chỉ chúc mừng khi đã lưu được, tránh ăn mừng rồi lại trừ ly.
      if (reachedGoal && mounted) {
        Celebration.confetti(
          context,
          emoji: '💧',
          title: 'Mẹ giỏi quá! 🎉',
          message:
              'Mẹ đã uống đủ $dailyCupGoal ly nước hôm nay.\nCơ thể mẹ và bé cảm ơn mẹ nhiều lắm!',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _waterCups = next - 1);
      _showAlert('Chưa lưu được', _errorMessage(e));
    }
  }

  Future<void> _chooseMood(int score) async {
    final previous = _moodScore;
    setState(() => _moodScore = score);
    if (score != previous) _rainMood(score);
    try {
      await DashboardRepository.saveDailyMonitoring({
        'moodScore': score,
        'moodNote': moodOptions.firstWhere((m) => m.score == score).label,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _moodScore = previous);
      _showAlert('Chưa lưu được', _errorMessage(e));
    }
  }

  /// Vài giọt nước rơi mỗi lần thêm ly.
  void _rainWaterDrops() {
    Celebration.rain(
      context,
      count: 20,
      minSize: 18,
      maxSize: 30,
      duration: const Duration(milliseconds: 1600),
      itemBuilder: (size) =>
          Icon(Icons.water_drop_rounded, size: size, color: _C.blue),
    );
  }

  /// Emoji của tâm trạng vừa chọn rơi khắp màn hình.
  void _rainMood(int score) {
    final option = moodOptions.firstWhere((m) => m.score == score);
    final asset = option.imageAsset;
    Celebration.rain(
      context,
      count: 28,
      minSize: 36,
      maxSize: 60,
      itemBuilder: (size) => asset != null
          ? Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _emojiText(option.emoji, size),
            )
          : _emojiText(option.emoji, size),
    );
  }

  /// Chọn từ thanh cảm xúc: chọn lại tâm trạng cũ thì chỉ cho emoji rơi.
  void _pickMood(MoodOption option) {
    if (option.score == _moodScore) {
      _rainMood(option.score);
    } else {
      _chooseMood(option.score);
    }
  }

  static Widget _emojiText(String emoji, double size) => FittedBox(
    child: Text(emoji, style: TextStyle(fontSize: size)),
  );

  String _errorMessage(Object e) => e is ApiException
      ? e.message
      : 'Không thể kết nối đến server. Vui lòng thử lại.';

  void _showAlert(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Tính năng đang được phát triển.')),
      );
  }

  /// Thẻ lộ trình ở trang chủ mở đúng màn của giai đoạn hiện tại.
  void _openStageFeature() {
    final screen = switch (_profile?.stage ?? 0) {
      1 => const PregnancyWeekScreen(),
      2 => const EpdsScreen(),
      _ => const OvulationCalendarScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// Mẹ đã thiết lập lộ trình thì mở ở chế độ xem / đổi lộ trình hiện tại,
  /// chưa thì mở màn chọn lộ trình như lúc mới đăng ký.
  Future<void> _openProfileSetup() async {
    final profile = _profile;
    final currentStage = profile == null || profile.needsSetup
        ? null
        : PregnancyStage.values[profile.stage];

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JourneySelectionScreen(currentStage: currentStage),
      ),
    );
    if (mounted) _loadAll();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Mẹ có chắc muốn đăng xuất khỏi Mom Ơi không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.rose),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Xóa access token + refresh token
      await AuthRepository.logout();
    } catch (_) {
      // Token cục bộ đã được xóa trong `finally` của logout.
    }
    if (!mounted) return;

    // Quay về Login và xóa toàn bộ navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = _profile?.stage ?? 0;
    final isPregnant = stage == 1;
    final isPostpartum = stage == 2;
    final week = _weekInfo?.week ?? _profile?.pregnancyWeek;
    final needsSetup = _profile?.needsSetup ?? false;
    final mood = moodOptions.where((m) => m.score == _moodScore).firstOrNull;
    final shortcut = _stageShortcut[stage]!;

    final stageTitle = isPregnant
        ? 'Thai kỳ hạnh phúc'
        : isPostpartum
        ? 'Chăm sóc hậu sản'
        : 'Chuẩn bị làm mẹ';

    final stageValue = isPregnant
        ? (week != null ? 'Tuần thứ $week' : 'Cập nhật tuần thai')
        : isPostpartum
        ? 'Phục hồi & chăm bé'
        : 'Theo dõi chu kỳ';

    final babySize = _weekInfo?.babySize;
    final stageNote = isPregnant
        ? (babySize != null && babySize.isNotEmpty
              ? 'Bé đang $babySize. ${_weekInfo?.development ?? ''}'
              : 'Mẹ nhập ngày kinh cuối trong hồ sơ để Mom Ơi tính tuần thai nhé.')
        : isPostpartum
        ? 'Mẹ nhớ dành thời gian nghỉ ngơi, uống canh ấm và ôm ấp bé yêu nhé.'
        : 'Thời điểm vàng để bổ sung acid folic và giữ tinh thần luôn thư thái.';

    return ColoredBox(
      color: MomTheme.cream,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: MomTheme.roseDark,
          onRefresh: _loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Bar ──
                AppHeader(
                  userName: _userName,
                  hasPendingAlerts: _pendingAlerts > 0,
                  onProfileTap: _openProfileSetup,
                  onNotificationsTap: _comingSoon,
                  onLogoutTap: _confirmLogout,
                ),
                const SizedBox(height: 20),

                // ── Gợi ý hoàn thiện hồ sơ cho người dùng mới ──
                if (needsSetup) ...[
                  _SetupCard(onTap: _openProfileSetup),
                  const SizedBox(height: 16),
                ],

                // ── Hero Milestone Card ──
                _HeroCard(
                  title: stageTitle,
                  value: stageValue,
                  note: stageNote,
                  onTap: () => widget.onSelectTab?.call(1),
                ),
                const SizedBox(height: 24),

                // ── Chăm sóc hôm nay ──
                const _SectionHeader(
                  title: 'Chăm sóc hôm nay',
                  subtitle: 'Mẹ nhớ lắng nghe cơ thể mình nhé',
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PriorityCard(
                          background: _C.waterBg,
                          iconBackground: _C.waterIconBg,
                          icon: LucideIcons.droplet,
                          iconColor: _C.blue,
                          value: '$_waterCups/$dailyCupGoal ly',
                          label: 'Uống nước',
                          footer: _QuickAddWater(onTap: _addWater),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PriorityCard(
                          background: _C.sleepBg,
                          iconBackground: _C.sleepIconBg,
                          icon: LucideIcons.moon,
                          iconColor: _C.purple,
                          value: _sleepHours != null
                              ? '${_formatNum(_sleepHours!)} giờ'
                              : '—',
                          label: 'Giấc ngủ',
                          onTap: _comingSoon,
                          footer: _StatusPill(
                            text: _sleepHours != null ? 'Đã ghi' : 'Ghi nhận',
                            background: _C.sleepIconBg,
                            color: _C.purple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PriorityCard(
                          background: _C.moodBg,
                          iconBackground: _C.moodIconBg,
                          icon: LucideIcons.heartPulse,
                          iconColor: MomTheme.roseDark,
                          value: mood?.emoji ?? '—',
                          // Chạm: emoji rơi; nhấn giữ: mở thanh chọn cảm xúc.
                          valueWidget: ReactionPicker<MoodOption>(
                            options: moodOptions,
                            selected: mood,
                            labelOf: (m) => m.label,
                            itemBuilder: (m, size) =>
                                _MoodIcon(option: m, height: size),
                            onSelected: _pickMood,
                            onTap: mood != null
                                ? () => _rainMood(mood.score)
                                : null,
                            child: mood != null
                                ? _MoodIcon(option: mood, height: 36)
                                : const _MoodPlaceholder(size: 36),
                          ),
                          label: 'Tâm trạng',
                          footer: _StatusPill(
                            text: mood?.label ?? 'Giữ để chọn',
                            background: _C.moodIconBg,
                            color: MomTheme.roseDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tiện ích cùng mẹ ──
                const _SectionHeader(
                  title: 'Tiện ích cùng mẹ',
                  subtitle: 'Trợ lý sức khỏe thông minh',
                ),
                _GridRow(
                  left: _GridCard(
                    iconBackground: AppColors.roseLight,
                    icon: LucideIcons.activity,
                    iconColor: MomTheme.roseDark,
                    title: 'Trợ lý sức khỏe AI',
                    sub: 'Hỏi an tâm mọi biểu hiện lạ',
                    onTap: () => widget.onSelectTab?.call(3),
                  ),
                  right: _GridCard(
                    iconBackground: MomTheme.sageLight,
                    icon: LucideIcons.baby,
                    iconColor: MomTheme.sageDark,
                    title: 'Bé yêu',
                    sub: 'Hồ sơ bé & thực đơn ăn dặm',
                    onTap: () => widget.onSelectTab?.call(2),
                  ),
                ),
                const SizedBox(height: 12),
                _GridRow(
                  left: _GridCard(
                    iconBackground: MomTheme.amberLight,
                    icon: LucideIcons.pill,
                    iconColor: MomTheme.amberDark,
                    title: 'Lịch uống thuốc',
                    sub: 'Vitamin, sắt, canxi mỗi ngày',
                    onTap: _comingSoon,
                  ),
                  right: _GridCard(
                    iconBackground: MomTheme.lavenderLight,
                    icon: LucideIcons.calendar,
                    iconColor: _C.purple,
                    title: shortcut.title,
                    sub: shortcut.sub,
                    onTap: _openStageFeature,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Ghi nhận trong ngày ──
                _CheckInCard(
                  waterCups: _waterCups,
                  moodScore: _moodScore,
                  onAddWater: _addWater,
                  onChooseMood: _chooseMood,
                  onOpenFullLog: _comingSoon,
                ),
                const SizedBox(height: 20),

                // ── Lời nhắn gửi mẹ ──
                const _WarmNoteCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatNum(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

// ─────────────────────────── Widgets ───────────────────────────

class _SetupCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SetupCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      borderRadius: 20,
      decoration: BoxDecoration(
        color: MomTheme.pinkLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MomTheme.pink),
        boxShadow: _shadowSm,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: MomTheme.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.userRound,
              size: 20,
              color: MomTheme.roseDark,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoàn thiện hồ sơ của mẹ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: MomTheme.roseDeep,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Chọn giai đoạn (chuẩn bị / mang thai / sau sinh) để Mom Ơi cá nhân hóa lộ trình.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 17 / 12,
                    color: MomTheme.charcoalMid,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: MomTheme.roseDark,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;
  final VoidCallback onTap;

  const _HeroCard({
    required this.title,
    required this.value,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: _shadowCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/pregnancy.jpg', fit: BoxFit.cover),
            const ColoredBox(color: Color(0x6B2C2118)), // rgba(44,33,24,.42)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xD9C97A95,
                          ), // rgba(201,122,149,.85)
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 13,
                              color: MomTheme.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: MomTheme.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: MomTheme.white,
                            shadows: [
                              Shadow(
                                color: Color(0x4D000000),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 18 / 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFBF8F5),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xEBFFFFFF,
                          ), // rgba(255,255,255,.92)
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Xem lộ trình của mẹ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: MomTheme.charcoal,
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: MomTheme.pinkLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.chevronRight,
                                size: 14,
                                color: MomTheme.roseDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MomTheme.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: MomTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final Color background;
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String value;

  /// Hiển thị thay cho [value] (vd. ảnh tâm trạng).
  final Widget? valueWidget;
  final String label;
  final Widget footer;
  final VoidCallback? onTap;

  const _PriorityCard({
    this.valueWidget,
    required this.background,
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.footer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      borderRadius: 20,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xCCFFFFFF)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          // Cao cố định bằng vòng tròn emoji để nhãn của 3 thẻ thẳng hàng.
          SizedBox(
            height: 36,
            child: Center(
              child:
                  valueWidget ??
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: MomTheme.charcoal,
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: MomTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}

class _QuickAddWater extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickAddWater({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MomTheme.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.plus, size: 13, color: _C.blue),
              SizedBox(width: 2),
              Text(
                '+1 ly',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color background;
  final Color color;

  const _StatusPill({
    required this.text,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _GridRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _GridCard({
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      borderRadius: 20,
      decoration: BoxDecoration(
        color: MomTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MomTheme.border),
        boxShadow: _shadowSm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: MomTheme.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              height: 15 / 11,
              color: MomTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final int waterCups;
  final int? moodScore;
  final VoidCallback onAddWater;
  final ValueChanged<int> onChooseMood;
  final VoidCallback onOpenFullLog;

  const _CheckInCard({
    required this.waterCups,
    required this.moodScore,
    required this.onAddWater,
    required this.onChooseMood,
    required this.onOpenFullLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MomTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MomTheme.border),
        boxShadow: _shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghi nhận trong ngày',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: MomTheme.charcoal,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tín hiệu nhỏ giúp Mom Ơi hiểu mẹ hơn mỗi ngày',
                      style: TextStyle(fontSize: 12, color: MomTheme.muted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: MomTheme.pinkLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: MomTheme.roseDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Water progress
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mục tiêu nước: $waterCups/$dailyCupGoal ly',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MomTheme.charcoal,
                  ),
                ),
              ),
              Material(
                color: _C.blue,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onAddWater,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.plus, size: 14, color: MomTheme.white),
                        SizedBox(width: 4),
                        Text(
                          'Thêm ly',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MomTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < dailyCupGoal; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: i < waterCups ? _C.blue : _C.waterTrack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Mood selector
          const Text(
            'Mẹ đang cảm thấy thế nào?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MomTheme.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in moodOptions)
                _MoodChip(
                  option: item,
                  active: moodScore == item.score,
                  onTap: () => onChooseMood(item.score),
                ),
            ],
          ),

          // Full log link
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: MomTheme.borderSoft),
          InkWell(
            onTap: onOpenFullLog,
            child: const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.clipboardList,
                    size: 15,
                    color: MomTheme.roseDark,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ghi nhật ký đầy đủ (giấc ngủ, bữa ăn, huyết áp...)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: MomTheme.roseDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 15,
                    color: MomTheme.roseDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final MoodOption option;
  final bool active;
  final VoidCallback onTap;

  const _MoodChip({
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? MomTheme.roseDark : MomTheme.cream,
      shape: StadiumBorder(
        side: BorderSide(color: active ? MomTheme.roseDark : MomTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 26,
                child: Center(child: _MoodIcon(option: option, height: 26)),
              ),
              const SizedBox(width: 5),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? MomTheme.white : MomTheme.charcoalMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Emoji tâm trạng, hoặc ảnh riêng (đặt trong nền tròn vàng) nếu
/// [MoodOption.imageAsset] có giá trị.
class _MoodIcon extends StatelessWidget {
  final MoodOption option;

  /// Đường kính nền tròn của ảnh; emoji chữ dùng cỡ chữ tương ứng.
  final double height;

  const _MoodIcon({required this.option, required this.height});

  @override
  Widget build(BuildContext context) {
    final emoji = Text(option.emoji, style: TextStyle(fontSize: height * 0.5));
    final asset = option.imageAsset;
    if (asset == null) return emoji;

    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        color: _C.moodImageBg,
        shape: BoxShape.circle,
        border: Border.all(color: MomTheme.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40C97A95),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      // Ảnh ngang (~3:2) nên chừa lề để nằm gọn trong vòng tròn.
      padding: EdgeInsets.all(height * 0.06),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => FittedBox(child: emoji),
      ),
    );
  }
}

/// Vòng tròn gợi ý chọn tâm trạng khi hôm nay mẹ chưa chọn.
class _MoodPlaceholder extends StatelessWidget {
  final double size;

  const _MoodPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MomTheme.white,
        shape: BoxShape.circle,
        border: Border.all(color: MomTheme.pink, width: 1.5),
      ),
      child: Icon(
        LucideIcons.smilePlus,
        size: size * 0.5,
        color: MomTheme.roseDark,
      ),
    );
  }
}

class _WarmNoteCard extends StatelessWidget {
  const _WarmNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.warmBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.warmBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _C.warmIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 20,
              color: MomTheme.amberDark,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lời nhắn gửi mẹ yêu 💛',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: MomTheme.amberDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hôm nay hãy dành cho bản thân ít phút thở sâu và nghe một bản nhạc êm dịu nhé. Nếu thấy bất kỳ cơn đau bất thường, ra máu hay thai máy giảm, mẹ hãy liên hệ bác sĩ ngay.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 18 / 12,
                    color: MomTheme.charcoalMid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ bấm được có hiệu ứng ripple (RN: TouchableOpacity).
class _Pressable extends StatelessWidget {
  final VoidCallback? onTap;
  final double borderRadius;
  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _Pressable({
    required this.onTap,
    required this.borderRadius,
    required this.decoration,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
