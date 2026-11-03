import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

/// Một câu hỏi EPDS với 4 lựa chọn, mỗi lựa chọn ứng với 0–3 điểm.
class EpdsQuestionCard extends StatelessWidget {
  const EpdsQuestionCard({
    super.key,
    required this.index,
    required this.total,
    required this.question,
    required this.selected,
    required this.onSelected,
  });

  final int index;
  final int total;
  final EpdsQuestion question;

  /// Điểm đã chọn (0–3), `null` khi mẹ chưa chọn.
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Câu ${index + 1}/$total',
                style: const TextStyle(
                  color: MomTheme.roseDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: 5,
                    backgroundColor: MomTheme.cream2,
                    valueColor: const AlwaysStoppedAnimation(MomTheme.roseDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            question.text,
            style: const TextStyle(
              color: MomTheme.charcoal,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          for (var score = 0; score < question.options.length; score++)
            _OptionTile(
              label: question.options[score],
              selected: selected == score,
              onTap: () => onSelected(score),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? MomTheme.pinkLight : MomTheme.creamSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
            side: BorderSide(
              color: selected ? MomTheme.roseDark : MomTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.control),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? LucideIcons.circleCheckBig
                        : LucideIcons.circle,
                    size: 18,
                    color: selected ? MomTheme.roseDark : MomTheme.mutedLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? MomTheme.roseDeep
                            : MomTheme.charcoalMid,
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
