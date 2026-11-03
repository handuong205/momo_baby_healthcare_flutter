import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/repositories/dashboard/dashboard_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/ovulation_calendar_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/journey_selection_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/epds_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/pregnancy_week_screen.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// Tab "Lộ trình": tóm tắt giai đoạn đang theo dõi và mở các màn của lộ trình.
class JourneyScreen extends StatefulWidget {
  /// `true` khi tab đang hiển thị; mỗi lần quay lại thì tải lại hồ sơ.
  final bool isActive;

  const JourneyScreen({super.key, this.isActive = true});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  DashboardProfile? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant JourneyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await DashboardRepository.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiError.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _load();
  }

  Future<void> _changeJourney() async {
    final stage = _profile?.stage;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JourneySelectionScreen(
          currentStage: stage == null
              ? null
              : PregnancyStage.values[stage.clamp(0, 2)],
        ),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _profile?.stage ?? 0;

    return MomScreen(
      eyebrow: 'Lộ trình của mẹ',
      title: switch (stage) {
        1 => 'Thai kỳ của mẹ',
        2 => 'Chặng sau sinh',
        _ => 'Chuẩn bị làm mẹ',
      },
      subtitle: 'Mọi bước của mẹ trong một chỗ, cập nhật theo hồ sơ hiện tại.',
      onRefresh: _load,
      children: [
        if (_loading)
          const MomLoadingView(text: 'Đang tải lộ trình...')
        else if (_error != null)
          MomStateCard.error(_error!, onRetry: _load)
        else ...[
          _StageCard(profile: _profile),
          const MomSectionTitle(
            title: 'Bước tiếp theo',
            subtitle: 'Chọn để mở từng phần của lộ trình',
          ),
          ..._featuresFor(stage).map(
            (feature) => _FeatureTile(
              feature: feature,
              onTap: () => _open(feature.open()),
            ),
          ),
          const SizedBox(height: 6),
          MomSecondaryButton(
            label: _profile?.needsSetup == true
                ? 'Thiết lập lộ trình'
                : 'Đổi lộ trình / cập nhật thông tin',
            icon: LucideIcons.route,
            onPressed: _changeJourney,
          ),
        ],
      ],
    );
  }

  /// Đưa phần đúng với giai đoạn hiện tại lên đầu, hai phần còn lại giữ nguyên.
  List<_JourneyFeature> _featuresFor(int stage) {
    final ordered = [..._journeyFeatures];
    if (stage == 1) ordered.insert(0, ordered.removeAt(1));
    if (stage == 2) ordered.insert(0, ordered.removeAt(2));
    return ordered;
  }
}

class _JourneyFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;
  final Widget Function() open;

  const _JourneyFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.background,
    required this.open,
  });
}

const _journeyFeatures = [
  _JourneyFeature(
    title: 'Lịch rụng trứng',
    subtitle: 'Ngày rụng trứng, cửa sổ thụ thai, kỳ kinh dự đoán',
    icon: LucideIcons.calendarHeart,
    color: MomTheme.roseDark,
    background: MomTheme.pinkLight,
    open: OvulationCalendarScreen.new,
  ),
  _JourneyFeature(
    title: 'Thai kỳ theo tuần',
    subtitle: 'Tuần thai, sự phát triển của bé, đếm cử động thai',
    icon: LucideIcons.baby,
    color: MomTheme.purple,
    background: MomTheme.lavenderLight,
    open: PregnancyWeekScreen.new,
  ),
  _JourneyFeature(
    title: 'Hồi phục & EPDS',
    subtitle: 'Bài test sàng lọc tinh thần sau sinh 10 câu',
    icon: LucideIcons.brain,
    color: MomTheme.sageDark,
    background: MomTheme.sageLight,
    open: EpdsScreen.new,
  ),
];

class _StageCard extends StatelessWidget {
  const _StageCard({required this.profile});

  final DashboardProfile? profile;

  @override
  Widget build(BuildContext context) {
    final stage = profile?.stage ?? 0;
    final week = profile?.pregnancyWeek;
    final needsSetup = profile?.needsSetup ?? false;

    final (String label, String value, String note) = switch (stage) {
      1 => (
        'Đang mang thai',
        week != null ? 'Tuần thứ $week' : 'Chưa có tuần thai',
        week != null
            ? 'Còn ${(40 - week).clamp(0, 40)} tuần nữa tới ngày dự sinh.'
            : 'Mẹ nhập ngày kinh cuối để tính tuần thai.',
      ),
      2 => (
        'Sau sinh',
        'Chăm sóc mẹ & bé',
        'Theo dõi hồi phục và sức khỏe tinh thần của mẹ.',
      ),
      _ => (
        'Chuẩn bị mang thai',
        'Theo dõi chu kỳ',
        'Ghi lại chu kỳ để dự đoán ngày dễ thụ thai.',
      ),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientPink,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.hero),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MomTheme.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: MomTheme.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: MomTheme.white,
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            needsSetup ? 'Hồ sơ chưa đủ thông tin để tính toán.' : note,
            style: const TextStyle(
              color: MomTheme.white,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          if (stage == 1 && week != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: week.clamp(0, 40) / 40,
                minHeight: 6,
                backgroundColor: MomTheme.white.withValues(alpha: 0.35),
                valueColor: const AlwaysStoppedAnimation(MomTheme.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.onTap});

  final _JourneyFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${feature.title}. ${feature.subtitle}',
    excludeSemantics: true,
    child: MomCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: feature.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, size: 19, color: feature.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        color: MomTheme.charcoal,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(feature.subtitle, style: MomText.muted),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: MomTheme.mutedLight,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
