import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/models/fertility/fertility_models.dart';
import 'package:momo_baby_healthcare_flutter/models/postpartum/epds.dart';
import 'package:momo_baby_healthcare_flutter/models/pregnancy/pregnancy_models.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/widget/cycle_month_grid.dart';
import 'package:momo_baby_healthcare_flutter/screens/fertility/widget/ovulation_status_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/postpartum/widget/epds_result_card.dart';
import 'package:momo_baby_healthcare_flutter/screens/pregnancy/widget/pregnancy_week_hero.dart';

/// Dựng từng widget với dữ liệu mẫu ở khổ điện thoại để bắt lỗi tràn layout.
Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: child,
    ),
  ),
);

void main() {
  setUp(() {
    // Khổ iPhone 12 Pro.
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
  });

  testWidgets('thẻ tuần thai hiển thị tuần và tam cá nguyệt', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PregnancyWeekHero(
          info: PregnancyWeekInfo(
            week: 26,
            babySize: 'bằng quả cà tím lớn 🍆',
            development: 'Bé đã mở mắt.',
            momTips: 'Làm xét nghiệm dung nạp đường huyết.',
          ),
        ),
      ),
    );

    expect(find.text('Tuần thai thứ 26'), findsOneWidget);
    expect(find.text('Tam cá nguyệt thứ 2'), findsOneWidget);
    expect(find.text('Còn 14 tuần nữa tới ngày dự sinh.'), findsOneWidget);
  });

  testWidgets('thẻ chi tiết tuần hiện kích thước, phát triển và lời khuyên', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const PregnancyWeekDetailCard(
          info: PregnancyWeekInfo(
            week: 26,
            babySize: 'bằng quả cà tím lớn',
            development: 'Phổi đang phát triển.',
            momTips: 'Uống đủ nước.',
          ),
        ),
      ),
    );

    expect(find.text('Bé đang bằng quả cà tím lớn'), findsOneWidget);
    expect(find.text('Phổi đang phát triển.'), findsOneWidget);
    expect(find.text('Uống đủ nước.'), findsOneWidget);
  });

  testWidgets('lịch tháng tô đúng ngày rụng trứng và kinh dự đoán', (
    tester,
  ) async {
    final calendar = FertilityCalendar.fromJson({
      'fertileWindowDays': ['2026-10-10T00:00:00Z', '2026-10-11T00:00:00Z'],
      'ovulationDay': '2026-10-11T00:00:00Z',
      'periodPrediction': '2026-10-29T00:00:00Z',
    });

    await tester.pumpWidget(
      _wrap(
        CycleMonthGrid(
          month: DateTime(2026, 10),
          calendar: calendar,
          onPrevMonth: () {},
          onNextMonth: () {},
        ),
      ),
    );

    expect(find.text('Tháng 10 • 2026'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Rụng trứng'), findsOneWidget);
  });

  testWidgets('thẻ trạng thái hôm nay nằm trong cửa sổ thụ thai', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const OvulationStatusCard(
          status: OvulationStatus(
            isInFertileWindow: true,
            daysUntilOvulation: 0,
            recommendation: 'Giữ tinh thần thoải mái.',
          ),
        ),
      ),
    );

    expect(
      find.text('Hôm nay mẹ đang trong cửa sổ thụ thai vàng'),
      findsOneWidget,
    );
    expect(find.text('Giữ tinh thần thoải mái.'), findsOneWidget);
  });

  testWidgets('kết quả EPDS mức cao có cảnh báo khẩn cấp', (tester) async {
    await tester.pumpWidget(
      _wrap(
        EpdsResultCard(
          outcome: EpdsOutcome.fromAnswers([2, 2, 2, 2, 2, 1, 1, 1, 0, 1]),
          savedToProfile: false,
          saveError: 'Vui lòng nâng cấp gói để sử dụng tính năng này.',
        ),
      ),
    );

    expect(find.text('14/30'), findsOneWidget);
    expect(find.textContaining('cấp cứu 115'), findsOneWidget);
    expect(find.textContaining('Chưa lưu được vào hồ sơ'), findsOneWidget);
  });
}
