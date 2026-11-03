import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/services/api_service.dart';
import 'package:momo_baby_healthcare_flutter/services/token_service.dart';

/// Giả lập backend: access token cũ bị 401, `refresh` đổi cả cặp token.
class _FakeBackend implements HttpClientAdapter {
  final List<String> calls = [];
  int refreshStatus = 200;

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options.path);
    if (options.path == '/api/auth/refresh') {
      if (refreshStatus != 200) {
        return _json(refreshStatus, {'success': false, 'message': 'Hết hạn'});
      }
      return _json(200, {
        'success': true,
        'data': {'token': 'new-access', 'refreshToken': 'new-refresh'},
      });
    }
    if (options.headers['Authorization'] == 'Bearer new-access') {
      return _json(200, {'success': true, 'data': 'ok'});
    }
    return _json(401, {'success': false, 'message': 'Unauthorized'});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeBackend backend;
  var expired = 0;

  setUpAll(() {
    dotenv.loadFromString(envString: 'ANDROID_API_URL=http://test\nWEB_API_URL=http://test');
    ApiService.initialize();
    ApiService.onSessionExpired = () => expired++;
  });

  setUp(() async {
    expired = 0;
    backend = _FakeBackend();
    ApiService.dio.httpClientAdapter = backend;
    FlutterSecureStorage.setMockInitialValues({});
    await TokenService.saveTokens(token: 'old-access', refreshToken: 'old-refresh');
  });

  test('gặp 401 thì refresh, lưu token mới và gửi lại request', () async {
    final response = await ApiService.get('/api/user-profile');

    expect(response.data['data'], 'ok');
    expect(await TokenService.getToken(), 'new-access');
    expect(await TokenService.getRefreshToken(), 'new-refresh');
    expect(expired, 0);
  });

  test('nhiều request 401 cùng lúc chỉ refresh một lần', () async {
    await Future.wait([
      ApiService.get('/api/alerts'),
      ApiService.get('/api/user-profile'),
      ApiService.get('/api/daily-monitoring/today'),
    ]);

    expect(backend.calls.where((p) => p == '/api/auth/refresh'), hasLength(1));
  });

  test('refresh token bị từ chối thì xóa phiên và báo hết hạn', () async {
    backend.refreshStatus = 401;

    await expectLater(
      ApiService.get('/api/user-profile'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );

    expect(await TokenService.getRefreshToken(), isNull);
    expect(expired, 1);
  });

  test('lỗi server khi refresh thì giữ nguyên phiên', () async {
    backend.refreshStatus = 500;

    await expectLater(
      ApiService.get('/api/user-profile'),
      throwsA(isA<ApiException>()),
    );

    expect(await TokenService.getRefreshToken(), 'old-refresh');
    expect(expired, 0);
  });

  test('API auth không tự refresh', () async {
    await expectLater(
      ApiService.post('/api/auth/login', requiresAuth: false),
      throwsA(isA<ApiException>()),
    );

    expect(backend.calls, ['/api/auth/login']);
  });
}
