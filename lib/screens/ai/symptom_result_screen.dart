import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/config/advisor_config.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/models/symptom/symptom_analysis.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/ai_ui.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/urgency_style.dart';

/// Màn 11 — Kết quả phân tích triệu chứng & liên hệ bác sĩ cố vấn.
class SymptomResultScreen extends StatelessWidget {
  final SymptomAnalysis analysis;

  const SymptomResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;

    return Scaffold(
      backgroundColor: MomTheme.cream,
      appBar: AppBar(
        backgroundColor: MomTheme.cream,
        title: const Text('Kết quả phân tích', style: AiText.section),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (!a.aiAvailable) ...[
              const _AiUnavailableCard(),
              const SizedBox(height: 14),
            ] else ...[
              _UrgencyHeader(analysis: a),
              const SizedBox(height: 14),
            ],

            if (a.isUrgent) ...[
              _SeeDoctorCard(specialist: a.specialistType),
              const SizedBox(height: 14),
            ],

            _YourSymptomCard(analysis: a),

            if (a.possibleConditions.isNotEmpty) ...[
              const SizedBox(height: 14),
              _ConditionsCard(conditions: a.possibleConditions),
            ],

            if (a.recommendations.isNotEmpty) ...[
              const SizedBox(height: 14),
              AiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      icon: Icons.check_circle_rounded,
                      title: 'Mẹ nên làm gì',
                      color: MomTheme.sageDark,
                      background: MomTheme.sageLight,
                    ),
                    AiBulletList(items: a.recommendations),
                  ],
                ),
              ),
            ],

            if (a.dietarySuggestions.isNotEmpty) ...[
              const SizedBox(height: 14),
              AiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      icon: Icons.eco_rounded,
                      title: 'Gợi ý ăn uống',
                      color: MomTheme.amberDark,
                      background: AppColors.amberLight,
                    ),
                    AiBulletList(items: a.dietarySuggestions, dotColor: MomTheme.amber),
                  ],
                ),
              ),
            ],

            if ((a.lifestyleConnection ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              AiCard(
                color: AppColors.blueLight,
                borderColor: AppColors.blue.withValues(alpha: 0.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      icon: Icons.spa_rounded,
                      title: 'Liên quan đến lối sống',
                      color: AppColors.blue,
                      background: MomTheme.white,
                    ),
                    const SizedBox(height: 10),
                    Text(a.lifestyleConnection!, style: AiText.body),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            DoctorCard(urgent: a.isUrgent),
            const SizedBox(height: 14),
            MedicalDisclaimer(
              extra: 'Nếu có dấu hiệu nguy hiểm, mẹ hãy đến cơ sở y tế gần nhất hoặc gọi '
                  '${AdvisorConfig.emergencyNumber}.',
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgencyHeader extends StatelessWidget {
  final SymptomAnalysis analysis;

  const _UrgencyHeader({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final s = UrgencyStyle.of(analysis.urgencyLevel);
    final score = analysis.severityScore.clamp(0, 100);

    return AiCard(
      color: s.background,
      borderColor: s.color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.icon, color: s.color, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mức độ cần chú ý', style: AiText.muted.copyWith(color: s.color)),
                    Text(s.label, style: AiText.title.copyWith(color: s.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              color: s.color,
              backgroundColor: MomTheme.white,
              semanticsLabel: 'Điểm mức độ $score trên 100',
            ),
          ),
          const SizedBox(height: 6),
          Text('Điểm đánh giá của AI: $score/100', style: AiText.muted),
          if ((analysis.urgencyReason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(analysis.urgencyReason!, style: AiText.body),
          ],
        ],
      ),
    );
  }
}

class _AiUnavailableCard extends StatelessWidget {
  const _AiUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return AiCard(
      color: AppColors.amberLight,
      borderColor: AppColors.amber.withValues(alpha: 0.5),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_rounded, color: MomTheme.amberDark, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI chưa phân tích được', style: AiText.label),
                SizedBox(height: 4),
                Text(
                  'Triệu chứng của mẹ đã được lưu, nhưng AI đang bận. Mẹ thử lại sau ít phút, '
                  'hoặc gọi bác sĩ cố vấn nếu thấy lo lắng.',
                  style: AiText.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeDoctorCard extends StatelessWidget {
  final String? specialist;

  const _SeeDoctorCard({this.specialist});

  @override
  Widget build(BuildContext context) {
    final hasSpecialist = (specialist ?? '').trim().isNotEmpty;
    return AiCard(
      color: AppColors.roseLight,
      borderColor: AppColors.rose.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_hospital_rounded, color: AppColors.rose, size: 28),
              SizedBox(width: 10),
              Expanded(child: Text('Mẹ nên đi khám sớm', style: AiText.section)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasSpecialist
                ? 'Nên gặp bác sĩ chuyên khoa: $specialist.'
                : 'Mẹ nên sắp xếp đi khám hoặc hỏi ý kiến bác sĩ càng sớm càng tốt.',
            style: AiText.body,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AiPillButton(
                icon: Icons.call_rounded,
                label: 'Gọi ${AdvisorConfig.doctorName}',
                background: AppColors.rose,
                onPressed: () => launchExternal(context, telUri(AdvisorConfig.doctorPhone)),
              ),
              AiPillButton(
                icon: Icons.emergency_rounded,
                label: 'Gọi ${AdvisorConfig.emergencyNumber}',
                outlined: true,
                foreground: AppColors.rose,
                onPressed: () => launchExternal(context, telUri(AdvisorConfig.emergencyNumber)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YourSymptomCard extends StatelessWidget {
  final SymptomAnalysis analysis;

  const _YourSymptomCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final image = _decodeImage(analysis.imageUrl);
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(icon: Icons.edit_note_rounded, title: 'Mẹ đã mô tả'),
          const SizedBox(height: 10),
          Text(analysis.textDescription, style: AiText.body),
          if (image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image,
            ),
          ],
          if (analysis.createdAt != null) ...[
            const SizedBox(height: 10),
            Text(formatViDateTime(analysis.createdAt), style: AiText.muted),
          ],
        ],
      ),
    );
  }

  /// Ảnh lưu dạng data URL base64 (hoặc link http).
  Widget? _decodeImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) {
      return Image.network(url, height: 180, width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink());
    }
    final comma = url.indexOf(',');
    if (!url.startsWith('data:') || comma < 0) return null;
    try {
      final bytes = base64Decode(url.substring(comma + 1));
      return Image.memory(bytes, height: 180, width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink());
    } catch (_) {
      return null;
    }
  }
}

class _ConditionsCard extends StatelessWidget {
  final List<PossibleCondition> conditions;

  const _ConditionsCard({required this.conditions});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            icon: Icons.psychology_alt_rounded,
            title: 'Tình trạng có thể gặp',
            color: MomTheme.lavender,
            background: MomTheme.lavenderLight,
          ),
          for (final c in conditions)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MomTheme.creamSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MomTheme.borderSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(c.name, style: AiText.label.copyWith(fontSize: 16))),
                      if (c.probability.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: MomTheme.lavenderLight,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            c.probability,
                            style: AiText.muted.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MomTheme.charcoalMid,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (c.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(c.description, style: AiText.body.copyWith(fontSize: 15)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
