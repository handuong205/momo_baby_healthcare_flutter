/// Bài test EPDS (Edinburgh Postnatal Depression Scale) — 10 câu, mỗi câu
/// 0–3 điểm, tổng 0–30. Thang chuẩn của Cox và cộng sự (1987).
///
/// Thứ tự [EpdsQuestion.options] đã xếp theo điểm tăng dần (index = điểm),
/// khớp với `answers` mà backend nhận ở `POST /api/postpartum/epds`.
library;

class EpdsQuestion {
  final String text;
  final List<String> options;

  const EpdsQuestion(this.text, this.options);
}

const List<EpdsQuestion> epdsQuestions = [
  EpdsQuestion('7 ngày qua, mẹ có thể cười và nhìn thấy mặt tích cực của mọi việc?', [
    'Nhiều như mọi khi',
    'Bớt hơn một chút',
    'Chắc chắn ít hơn nhiều',
    'Không hề',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có mong chờ những việc sắp tới một cách vui vẻ?', [
    'Nhiều như mọi khi',
    'Ít hơn trước một chút',
    'Chắc chắn ít hơn nhiều',
    'Hầu như không',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có tự trách mình vô cớ khi có việc không suôn sẻ?', [
    'Có, hầu hết thời gian',
    'Có, thỉnh thoảng',
    'Không thường xuyên',
    'Không, không bao giờ',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có lo lắng hoặc bồn chồn mà không rõ lý do?', [
    'Không, không hề',
    'Hầu như không',
    'Có, thỉnh thoảng',
    'Có, rất thường xuyên',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có cảm thấy sợ hãi hoặc hoảng hốt vô cớ?', [
    'Không, không hề',
    'Không nhiều',
    'Có, thỉnh thoảng',
    'Có, khá nhiều',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có cảm thấy mọi việc vượt quá sức mình?', [
    'Không, mẹ vẫn xoay xở tốt như trước',
    'Không, phần lớn thời gian mẹ vẫn ổn',
    'Có, đôi khi mẹ không xoay xở tốt như thường',
    'Có, phần lớn thời gian mẹ không thể xoay xở',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có buồn đến mức khó ngủ?', [
    'Không, không hề',
    'Không thường xuyên',
    'Có, thỉnh thoảng',
    'Có, hầu hết thời gian',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có cảm thấy buồn bã hoặc khổ sở?', [
    'Không, không hề',
    'Không thường xuyên',
    'Có, khá thường xuyên',
    'Có, hầu hết thời gian',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có buồn đến mức khóc?', [
    'Không, không bao giờ',
    'Chỉ thỉnh thoảng',
    'Có, khá thường xuyên',
    'Có, hầu hết thời gian',
  ]),
  EpdsQuestion('7 ngày qua, mẹ có từng nghĩ đến việc làm hại bản thân?', [
    'Không bao giờ',
    'Hầu như không',
    'Thỉnh thoảng',
    'Có, khá thường xuyên',
  ]),
];

enum EpdsLevel { low, moderate, high }

/// Kết quả tính tại máy. Backend chỉ lưu điểm, không trả mức độ.
class EpdsOutcome {
  final int score;
  final EpdsLevel level;
  final bool selfHarmRisk;

  const EpdsOutcome({
    required this.score,
    required this.level,
    required this.selfHarmRisk,
  });

  factory EpdsOutcome.fromAnswers(List<int> answers) {
    final score = answers.fold<int>(0, (sum, a) => sum + a);
    // Câu 10 (tự làm hại bản thân) khác 0 là phải can thiệp ngay, bất kể tổng điểm.
    final selfHarmRisk = answers.length >= 10 && answers[9] > 0;
    final level = selfHarmRisk || score >= 13
        ? EpdsLevel.high
        : score >= 10
        ? EpdsLevel.moderate
        : EpdsLevel.low;
    return EpdsOutcome(score: score, level: level, selfHarmRisk: selfHarmRisk);
  }

  String get title => switch (level) {
    EpdsLevel.low => 'Tinh thần của mẹ đang ổn định 🌿',
    EpdsLevel.moderate => 'Mẹ nên theo dõi thêm 💛',
    EpdsLevel.high => 'Mẹ cần được hỗ trợ sớm 🤍',
  };

  String get advice => switch (level) {
    EpdsLevel.low =>
      'Điểm dưới 10: chưa thấy dấu hiệu trầm cảm sau sinh. Mẹ tiếp tục nghỉ ngơi, '
          'chia sẻ với người thân và làm lại bài test sau 2 tuần nhé.',
    EpdsLevel.moderate =>
      'Điểm 10–12: có dấu hiệu cần quan tâm. Mẹ hãy nói chuyện với người thân hoặc '
          'nhân viên y tế, và làm lại bài test sau 2 tuần.',
    EpdsLevel.high =>
      'Điểm từ 13 trở lên: mẹ nên gặp bác sĩ hoặc chuyên gia tâm lý sớm để được '
          'đánh giá và hỗ trợ. Mẹ không cần tự vượt qua việc này một mình.',
  };
}

/// Một lần đánh giá đã lưu (`GET /api/postpartum/epds/latest`).
class EpdsAssessment {
  final int? score;
  final String? severity;
  final DateTime? assessedAt;

  const EpdsAssessment({this.score, this.severity, this.assessedAt});

  factory EpdsAssessment.fromJson(Map<String, dynamic> json) {
    return EpdsAssessment(
      score: (json['score'] as num?)?.toInt() ?? (json['totalScore'] as num?)?.toInt(),
      severity: (json['severity'] ?? json['level'])?.toString(),
      assessedAt: DateTime.tryParse(
        (json['assessedAt'] ?? json['createdAt'] ?? '').toString(),
      ),
    );
  }
}
