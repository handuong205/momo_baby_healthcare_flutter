import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';
import 'package:momo_baby_healthcare_flutter/repositories/postpartum/epds_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/widget/epds_question_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/widget/epds_result_card.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';

enum _Phase { intro, questions, result }

/// (6) Hồi phục & EPDS — bài test 10 câu, chấm điểm ngay trên máy và gửi
/// kết quả lên hồ sơ nếu backend cho phép.
class EpdsScreen extends StatefulWidget {
  const EpdsScreen({super.key});

  @override
  State<EpdsScreen> createState() => _EpdsScreenState();
}

class _EpdsScreenState extends State<EpdsScreen> {
  _Phase _phase = _Phase.intro;
  int _index = 0;
  final List<int?> _answers = List<int?>.filled(epdsQuestions.length, null);

  EpdsAssessment? _latest;
  EpdsOutcome? _outcome;
  String? _saveError;
  bool? _saved;
  bool _submitting = false;
  String? _loadNotice;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    try {
      final latest = await EpdsRepository.latest();
      if (!mounted) return;
      setState(() => _latest = latest);
    } catch (e) {
      if (!mounted) return;
      // Gói miễn phí bị chặn: vẫn cho làm bài và xem điểm tại máy.
      setState(() => _loadNotice = ApiError.getErrorMessage(e));
    }
  }

  void _start() {
    setState(() {
      _phase = _Phase.questions;
      _index = 0;
      _outcome = null;
      _saved = null;
      _saveError = null;
      for (var i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
    });
  }

  void _select(int score) {
    setState(() => _answers[_index] = score);
    if (_index < epdsQuestions.length - 1) {
      setState(() => _index++);
    }
  }

  void _back() {
    if (_index == 0) {
      setState(() => _phase = _Phase.intro);
    } else {
      setState(() => _index--);
    }
  }

  Future<void> _submit() async {
    final answers = _answers.whereType<int>().toList();
    if (answers.length < epdsQuestions.length) return;

    setState(() {
      _submitting = true;
      _outcome = EpdsOutcome.fromAnswers(answers);
      _phase = _Phase.result;
    });

    try {
      await EpdsRepository.submit(answers);
      if (!mounted) return;
      setState(() => _saved = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saved = false;
        _saveError = ApiError.getErrorMessage(e);
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _answeredCurrent => _answers[_index] != null;

  @override
  Widget build(BuildContext context) {
    return MomScreen(
      eyebrow: 'Chăm sóc tinh thần',
      title: 'Hồi phục & EPDS',
      subtitle: _phase == _Phase.questions
          ? 'Chọn câu trả lời đúng nhất với 7 ngày qua của mẹ.'
          : 'Bài test sàng lọc trầm cảm sau sinh, 10 câu, khoảng 3 phút.',
      children: switch (_phase) {
        _Phase.intro => _introChildren(),
        _Phase.questions => _questionChildren(),
        _Phase.result => _resultChildren(),
      },
    );
  }

  List<Widget> _introChildren() => [
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
                  color: MomTheme.pinkLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.brain,
                  size: 19,
                  color: MomTheme.roseDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('EPDS là gì?', style: MomText.label)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'EPDS (Edinburgh Postnatal Depression Scale) gồm 10 câu hỏi về cảm '
            'xúc trong 7 ngày qua. Bài test giúp mẹ nhận biết sớm dấu hiệu trầm '
            'cảm sau sinh — không thay thế chẩn đoán của bác sĩ.',
            style: MomText.body,
          ),
        ],
      ),
    ),
    if (_latest != null)
      MomCard(
        color: MomTheme.sageLight,
        borderColor: MomTheme.sage,
        child: Row(
          children: [
            const Icon(LucideIcons.history, size: 17, color: MomTheme.sageDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Lần gần nhất: ${_latest!.score ?? '—'}/30'
                '${_latest!.severity != null ? ' • ${_latest!.severity}' : ''}',
                style: const TextStyle(
                  color: MomTheme.sageDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    if (_loadNotice != null)
      MomCard(
        color: MomTheme.cream2,
        borderColor: MomTheme.border,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.lock, size: 16, color: MomTheme.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mẹ vẫn làm được bài test và xem điểm ngay trên máy. '
                'Việc lưu vào hồ sơ đang bị chặn: $_loadNotice',
                style: MomText.muted,
              ),
            ),
          ],
        ),
      ),
    MomPrimaryButton(
      label: 'Bắt đầu bài test',
      icon: LucideIcons.clipboardList,
      onPressed: _start,
    ),
  ];

  List<Widget> _questionChildren() {
    final isLast = _index == epdsQuestions.length - 1;
    return [
      EpdsQuestionCard(
        index: _index,
        total: epdsQuestions.length,
        question: epdsQuestions[_index],
        selected: _answers[_index],
        onSelected: _select,
      ),
      Row(
        children: [
          Expanded(
            child: MomSecondaryButton(
              label: _index == 0 ? 'Thoát' : 'Câu trước',
              icon: LucideIcons.arrowLeft,
              onPressed: _back,
            ),
          ),
          if (isLast) ...[
            const SizedBox(width: 10),
            Expanded(
              child: MomPrimaryButton(
                label: 'Xem kết quả',
                loading: _submitting,
                icon: LucideIcons.check,
                onPressed: _answeredCurrent ? _submit : null,
              ),
            ),
          ],
        ],
      ),
    ];
  }

  List<Widget> _resultChildren() => [
    if (_outcome != null)
      EpdsResultCard(
        outcome: _outcome!,
        savedToProfile: _saved,
        saveError: _saveError,
      ),
    MomPrimaryButton(
      label: 'Làm lại bài test',
      icon: LucideIcons.rotateCcw,
      onPressed: _start,
    ),
    const SizedBox(height: 10),
    MomSecondaryButton(
      label: 'Đóng',
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  ];
}
