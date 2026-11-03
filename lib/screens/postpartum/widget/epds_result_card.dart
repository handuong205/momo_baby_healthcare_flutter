import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// Kết quả bài test EPDS: điểm, mức độ và lời khuyên.
class EpdsResultCard extends StatelessWidget {
  const EpdsResultCard({
    super.key,
    required this.outcome,
    this.savedToProfile,
    this.saveError,
  });

  final EpdsOutcome outcome;

  /// `null` khi chưa gửi được lên hồ sơ.
  final bool? savedToProfile;
  final String? saveError;

  Color get _accent => switch (outcome.level) {
    EpdsLevel.low => MomTheme.sageDark,
    EpdsLevel.moderate => MomTheme.amberDark,
    EpdsLevel.high => MomTheme.danger,
  };

  Color get _surface => switch (outcome.level) {
    EpdsLevel.low => MomTheme.sageLight,
    EpdsLevel.moderate => MomTheme.amberLight,
    EpdsLevel.high => MomTheme.dangerLight,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MomCard(
          color: _surface,
          borderColor: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: MomTheme.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _accent),
                    ),
                    child: Icon(
                      outcome.level == EpdsLevel.low
                          ? LucideIcons.leaf
                          : LucideIcons.heartHandshake,
                      size: 21,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ĐIỂM EPDS CỦA MẸ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: MomTheme.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${outcome.score}/30',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 26,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                outcome.title,
                style: const TextStyle(
                  color: MomTheme.charcoal,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                outcome.advice,
                style: const TextStyle(
                  color: MomTheme.charcoalMid,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        if (outcome.selfHarmRisk) ...[
          MomWarning(
            'Mẹ đã chọn câu trả lời về việc làm hại bản thân. Hãy liên hệ ngay '
            'người thân hoặc gọi cấp cứu 115 / đến cơ sở y tế gần nhất. Mẹ '
            'không phải chịu đựng việc này một mình.',
            icon: LucideIcons.phoneCall,
          ),
          const SizedBox(height: 6),
        ],
        if (savedToProfile == true)
          _note(
            icon: LucideIcons.checkCheck,
            text: 'Kết quả đã được lưu vào hồ sơ sức khỏe của mẹ.',
            color: MomTheme.sageDark,
          )
        else if (saveError != null)
          _note(
            icon: LucideIcons.cloudOff,
            text: 'Chưa lưu được vào hồ sơ: $saveError',
            color: MomTheme.amberDark,
          ),
      ],
    );
  }

  Widget _note({
    required IconData icon,
    required String text,
    required Color color,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: MomTheme.cream2,
      borderRadius: BorderRadius.circular(AppRadii.control),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 12, height: 1.45),
          ),
        ),
      ],
    ),
  );
}
