import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/screens/baby/baby_screen.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';
import 'package:momo_baby_healthcare_flutter/utils/who_data.dart';

/// Backend giả: lưu số đo thật sự, `profiles` trả về danh sách hiện tại.
class _FakeBackend implements HttpClientAdapter {
  final List<Map<String, dynamic>> records = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object? data;
    if (options.path == '/api/baby/profiles') {
      data = [
        {
          'id': 1,
          'babyName': 'Bé Na',
          'dateOfBirth': DateTime.now()
              .toUtc()
              .subtract(const Duration(days: 60))
              .toIso8601String(),
          'gender': 'Female',
          'currentWeightKg': records.isEmpty ? 3.4 : records.last['weightKg'],
          'currentHeightCm': records.isEmpty ? 50 : records.last['heightCm'],
          'ageMonths': 2,
          'allergies': const <String>[],
          'foodHistory': const <String>[],
          'growthRecords': records,
        },
      ];
    } else if (options.path == '/api/baby/1/growth') {
      records.add({'id': records.length + 1, ...options.data as Map});
      data = {'feedback': 'Đã lưu'};
    }
    return ResponseBody.fromString(
      jsonEncode({'success': true, 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'ANDROID_API_URL=http://test\nWEB_API_URL=http://test',
    );
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('số đo vừa ghi vẫn còn khi thoát ra rồi mở lại biểu đồ', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ApiService.dio.httpClientAdapter = _FakeBackend();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BabyScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Biểu đồ tăng trưởng'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa có mốc tăng trưởng'), findsOneWidget);

    await tester.tap(find.text('Ghi số đo mới'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '5.2');
    await tester.enterText(find.byType(TextField).at(1), '58');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('5.2 kg · 58.0 cm'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    // Thẻ hồ sơ ở màn Bé yêu cũng cập nhật số đo mới.
    expect(find.textContaining('5.2 kg'), findsOneWidget);

    await tester.tap(find.text('Biểu đồ tăng trưởng'));
    await tester.pump();
    // Ngay khi mở (chưa cần chờ tải lại) đã có số đo, không còn dữ liệu cũ.
    expect(find.text('5.2 kg · 58.0 cm'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('5.2 kg · 58.0 cm'), findsOneWidget);
    expect(find.text('Cân nặng theo tuổi'), findsOneWidget);

    await tester.tap(find.text('Chiều cao'));
    await tester.pumpAndSettle();
    expect(find.text('Chiều cao theo tuổi'), findsOneWidget);
  });

  test('khoảng tháng và bước chia của biểu đồ', () {
    expect(growthChartWindow(0.5), 6);
    expect(growthChartWindow(6), 6);
    expect(growthChartWindow(7), 12);
    expect(growthChartWindow(30), 24);
    expect(growthChartStep(7), 2);
    expect(growthChartStep(25), 5);
    expect(growthChartStep(50), 10);
  });
}
