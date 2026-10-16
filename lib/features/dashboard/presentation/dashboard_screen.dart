import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/state/auth_controller.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_models.dart';
import '../state/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.repository});

  final DashboardRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = DashboardController(widget.repository);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Mẹ có chắc muốn đăng xuất khỏi Mom Ơi không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthController>().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/landing', (_) => false);
    }
  }

  Future<void> performAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      if (error is DashboardActionException) {
        await _alert(error.title, error.message);
      } else {
        await _alert('Chưa lưu được', error.toString());
      }
    }
  }

  Future<void> _alert(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: controller,
    child: Consumer<DashboardController>(
      builder: (context, data, _) {
        final user = context.watch<AuthController>().user;
        final stage = data.stage;
        final pregnant = stage == 1;
        final postpartum = stage == 2;
        final week = data.weekInfo?.week ?? data.profile?.pregnancyWeek;
        final stageTitle = pregnant
            ? 'Thai kỳ hạnh phúc'
            : postpartum
            ? 'Chăm sóc hậu sản'
            : 'Chuẩn bị làm mẹ';
        final stageValue = pregnant
            ? week != null
                  ? 'Tuần thứ $week'
                  : 'Cập nhật tuần thai'
            : postpartum
            ? 'Phục hồi & chăm bé'
            : 'Theo dõi chu kỳ';
        final stageNote = pregnant
            ? data.weekInfo?.babySize != null
                  ? 'Bé đang ${data.weekInfo!.babySize}. ${data.weekInfo!.development ?? ''}'
                  : 'Mẹ nhập ngày kinh cuối trong hồ sơ để Mom Ơi tính tuần thai nhé.'
            : postpartum
            ? 'Mẹ nhớ dành thời gian nghỉ ngơi, uống canh ấm và ôm ấp bé yêu nhé.'
            : 'Thời điểm vàng để bổ sung acid folic và giữ tinh thần luôn thư thái.';
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: data.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(user?.fullName, data.pendingAlerts, logout),
                    if (data.needsSetup) _setupCard(),
                    _heroCard(stageTitle, stageValue, stageNote),
                    _sectionHeader(
                      'Chăm sóc hôm nay',
                      'Mẹ nhớ lắng nghe cơ thể mình nhé',
                    ),
                    _priorityRow(data),
                    _sectionHeader(
                      'Tiện ích cùng mẹ',
                      'Trợ lý sức khỏe thông minh',
                    ),
                    _quickTools(stage),
                    _checkInCard(data),
                    _warmNote(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _topBar(String? fullName, int alerts, VoidCallback onLogout) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: () => Navigator.pushNamed(context, '/profile'),
        borderRadius: BorderRadius.circular(28),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.pink,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🌸', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào mẹ,',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                Text(
                  fullName ?? 'Mẹ yêu',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Row(
        children: [
          _roundAction(
            LucideIcons.bell,
            alerts > 0,
            () => Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(width: 8),
          _roundAction(LucideIcons.logOut, false, onLogout, pink: true),
        ],
      ),
    ],
  );

  Widget _roundAction(
    IconData icon,
    bool badge,
    VoidCallback? onTap, {
    bool pink = false,
  }) => Stack(
    children: [
      IconButton(
        onPressed: onTap,
        style: IconButton.styleFrom(
          fixedSize: const Size(42, 42),
          backgroundColor: pink ? AppColors.pinkLight : AppColors.white,
          side: BorderSide(color: pink ? AppColors.pink : AppColors.border),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: pink ? AppColors.primaryDark : AppColors.charcoalMid,
        ),
      ),
      if (badge)
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  );

  Widget _setupCard() => InkWell(
    onTap: () => Navigator.pushNamed(context, '/profile'),
    borderRadius: BorderRadius.circular(AppRadii.card),
    child: _Card(
      color: AppColors.pinkLight,
      borderColor: AppColors.pink,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.white,
            child: Icon(
              LucideIcons.user,
              size: 20,
              color: AppColors.primaryDark,
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
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Chọn giai đoạn (chuẩn bị / mang thai / sau sinh) để Mom Ơi cá nhân hóa lộ trình.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.charcoalMid,
                  ),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.primaryDark),
        ],
      ),
    ),
  );

  Widget _heroCard(String title, String value, String note) => InkWell(
    onTap: () => Navigator.pushNamed(context, '/daily-monitoring'),
    borderRadius: BorderRadius.circular(24),
    child: Container(
      height: 190,
      margin: const EdgeInsets.only(top: 4, bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/pregnancy.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color.fromRGBO(44, 33, 24, 0.42),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.sparkles, size: 13, color: AppColors.white),
                  SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.38,
              color: Color(0xFFFBF8F5),
            ),
          ),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Xem lộ trình của mẹ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sectionHeader(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    ),
  );

  Widget _priorityRow(DashboardController data) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _PriorityCard(
          color: const Color(0xFFF0F6FB),
          iconColor: const Color(0xFF4A88C7),
          iconBackground: const Color(0xFFDCEBFA),
          icon: LucideIcons.droplet,
          value: '${data.waterCups}/10 ly',
          label: 'Uống nước',
          child: _smallButton(
            '+1 ly',
            const Color(0xFF4A88C7),
            () => performAction(data.addWater),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _PriorityCard(
          color: const Color(0xFFF6F2FB),
          iconColor: const Color(0xFF8E6BB8),
          iconBackground: const Color(0xFFEADFF8),
          icon: LucideIcons.moon,
          value: data.sleepHours == null ? '—' : '${data.sleepHours} giờ',
          label: 'Giấc ngủ',
          child: _statusPill(
            data.sleepHours == null ? 'Ghi nhận' : 'Đã ghi',
            const Color(0xFF8E6BB8),
            const Color(0xFFEADFF8),
            onTap: () => Navigator.pushNamed(context, '/daily-monitoring'),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _PriorityCard(
          color: const Color(0xFFFCF2F4),
          iconColor: AppColors.primaryDark,
          iconBackground: const Color(0xFFF9DCE3),
          icon: LucideIcons.heartPulse,
          value: data.moodScore == null
              ? '—'
              : moodOptions[data.moodScore! - 1].emoji,
          label: 'Tâm trạng',
          child: _statusPill(
            data.moodScore == null
                ? 'Chưa chọn'
                : moodOptions[data.moodScore! - 1].label,
            AppColors.primaryDark,
            const Color(0xFFF9DCE3),
          ),
        ),
      ),
    ],
  );

  Widget _smallButton(String text, Color color, VoidCallback onTap) =>
      TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: color,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );

  Widget _statusPill(
    String text,
    Color color,
    Color background, {
    VoidCallback? onTap,
  }) {
    final pill = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
    return onTap == null
        ? pill
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: pill,
          );
  }

  Widget _quickTools(int stage) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.35,
    children: [
      _ToolCard(
        icon: LucideIcons.activity,
        iconColor: AppColors.primaryDark,
        iconBackground: AppColors.roseLight,
        title: 'Trợ lý sức khỏe AI',
        subtitle: 'Hỏi an tâm mọi biểu hiện lạ',
        onTap: () => Navigator.pushNamed(context, '/main', arguments: 3),
      ),
      _ToolCard(
        icon: LucideIcons.baby,
        iconColor: AppColors.sageDark,
        iconBackground: AppColors.sageLight,
        title: 'Bé yêu',
        subtitle: 'Hồ sơ bé & thực đơn ăn dặm',
        onTap: () => Navigator.pushNamed(context, '/main', arguments: 2),
      ),
      _ToolCard(
        icon: LucideIcons.pill,
        iconColor: AppColors.amberDark,
        iconBackground: Color(0xFFFFF4EB),
        title: 'Lịch uống thuốc',
        subtitle: 'Vitamin, sắt, canxi mỗi ngày',
        onTap: () => Navigator.pushNamed(context, '/medications'),
      ),
      _ToolCard(
        icon: LucideIcons.calendar,
        iconColor: Color(0xFF8E6BB8),
        iconBackground: Color(0xFFF3EEF8),
        title: 'Chu kỳ & rụng trứng',
        subtitle: 'Dự đoán ngày dễ thụ thai',
        onTap: () {},
      ),
    ],
  );

  Widget _checkInCard(DashboardController data) => _Card(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(top: 24, bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ghi nhận trong ngày',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tín hiệu nhỏ giúp Mom Ơi hiểu mẹ hơn mỗi ngày',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: AppColors.pinkLight,
              child: Icon(
                LucideIcons.heart,
                size: 18,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mục tiêu nước: ${data.waterCups}/10 ly',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => performAction(data.addWater),
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Thêm ly'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A88C7),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            10,
            (index) => Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: index == 9 ? 0 : 5),
                decoration: BoxDecoration(
                  color: index < data.waterCups
                      ? const Color(0xFF4A88C7)
                      : const Color(0xFFEAE6DF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Mẹ đang cảm thấy thế nào?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: moodOptions
              .map(
                (item) => _MoodChip(
                  option: item,
                  active: data.moodScore == item.score,
                  onTap: () => performAction(() => data.chooseMood(item.score)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        const Divider(color: AppColors.borderSoft),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/daily-monitoring'),
          child: Row(
            children: [
              Icon(
                LucideIcons.clipboardList,
                size: 15,
                color: AppColors.primaryDark,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ghi nhật ký đầy đủ (giấc ngủ, bữa ăn, huyết áp...)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 15,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _warmNote() => _Card(
    color: const Color(0xFFFFF8F0),
    borderColor: const Color(0xFFF7E7D0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFFFE9D4),
          child: Icon(
            LucideIcons.sparkles,
            size: 20,
            color: AppColors.amberDark,
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
                  color: AppColors.amberDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Hôm nay hãy dành cho bản thân ít phút thở sâu và nghe một bản nhạc êm dịu nhé. Nếu thấy bất kỳ cơn đau bất thường, ra máu hay thai máy giảm, mẹ hãy liên hệ bác sĩ ngay.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.charcoalMid,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.color = AppColors.white,
    this.borderColor = AppColors.borderSoft,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final EdgeInsets padding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadii.card),
      border: Border.all(color: borderColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D2C2118),
          offset: Offset(0, 6),
          blurRadius: 14,
        ),
      ],
    ),
    child: child,
  );
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.color,
    required this.iconColor,
    required this.iconBackground,
    required this.icon,
    required this.value,
    required this.label,
    required this.child,
  });

  final Color color;
  final Color iconColor;
  final Color iconBackground;
  final IconData icon;
  final String value;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: iconBackground,
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
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
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.option,
    required this.active,
    required this.onTap,
  });

  final MoodOption option;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadii.pill),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryDark : AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: active ? AppColors.primaryDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(option.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            option.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.white : AppColors.charcoalMid,
            ),
          ),
        ],
      ),
    ),
  );
}
