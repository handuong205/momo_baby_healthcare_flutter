import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/models/pregnancy/pregnancy_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/pregnancy/pregnancy_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/pregnancy_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/widget/kick_counter_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/widget/pregnancy_week_hero.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// (5) Thai kỳ theo tuần — tuần hiện tại, nội dung tuần, đếm cử động thai.
class PregnancyWeekScreen extends StatefulWidget {
  const PregnancyWeekScreen({super.key});

  @override
  State<PregnancyWeekScreen> createState() => _PregnancyWeekScreenState();
}

class _PregnancyWeekScreenState extends State<PregnancyWeekScreen> {
  PregnancyWeekInfo? _info;
  int _steps = 0;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final info = await PregnancyRepository.thisWeek();
      // Số bước là thông tin phụ, lỗi thì bỏ qua chứ không chặn cả màn.
      var steps = 0;
      try {
        steps = await PregnancyRepository.todaySteps();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _info = info;
        _steps = steps;
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

  bool get _needsPregnancySetup =>
      _error != null && _error!.toLowerCase().contains('mang thai');

  Future<void> _openSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PregnancyScreen()),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return MomScreen(
      eyebrow: 'Hành trình 40 tuần',
      title: 'Thai kỳ theo tuần',
      subtitle: 'Theo dõi bé lớn lên từng tuần và ghi lại cử động thai.',
      onRefresh: _load,
      children: [
        if (_loading)
          const MomLoadingView(text: 'Đang tải tuần thai...')
        else if (_needsPregnancySetup)
          MomStateCard(
            emoji: '🤰',
            title: 'Chưa thiết lập thai kỳ',
            body: _error,
            action: MomPrimaryButton(
              label: 'Thiết lập thai kỳ',
              icon: LucideIcons.calendarPlus,
              onPressed: _openSetup,
            ),
          )
        else if (_error != null)
          MomStateCard.error(_error!, onRetry: _load)
        else if (_info != null) ...[
          PregnancyWeekHero(info: _info!),
          PregnancyWeekDetailCard(info: _info!),
          MomCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: MomTheme.sageLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.footprints,
                    size: 19,
                    color: MomTheme.sageDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bước chân hôm nay', style: MomText.label),
                      const SizedBox(height: 2),
                      Text(
                        '$_steps bước',
                        style: const TextStyle(
                          color: MomTheme.charcoalMid,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const KickCounterCard(),
        ],
      ],
    );
  }
}
