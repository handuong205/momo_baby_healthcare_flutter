import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const tokenKey = '@momoi_token';
  static const refreshTokenKey = '@momoi_refresh_token';
  static const userKey = '@momoi_user';
  static const tierKey = '@momoi_tier';

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> saveSession({
    required String token,
    required String? refreshToken,
    required Map<String, dynamic> user,
    required String tier,
  }) async {
    await Future.wait([
      write(tokenKey, token),
      write(refreshTokenKey, refreshToken ?? ''),
      write(userKey, jsonEncode(user)),
      write(tierKey, tier),
    ]);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: tokenKey),
      _storage.delete(key: refreshTokenKey),
      _storage.delete(key: userKey),
      _storage.delete(key: tierKey),
    ]);
  }
}
