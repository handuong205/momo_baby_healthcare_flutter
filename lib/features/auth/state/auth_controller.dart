import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/auth_repository.dart';
import '../models/user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this.repository);

  final AuthRepository repository;
  UserModel? user;
  bool isLoading = true;
  String? error;

  bool get isAuthenticated => user != null;

  Future<void> init() async {
    try {
      user = await repository.restoreSession();
    } catch (_) {
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await repository.login(email.trim(), password);
      return true;
    } catch (exception) {
      error = _message(
        exception,
        'Không thể kết nối đến máy chủ. Vui lòng thử lại.',
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(
    String email,
    String password,
    String fullName,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      return await repository.register(email.trim(), password, fullName.trim());
    } catch (exception) {
      error = _message(exception, 'Không thể hoàn tất đăng ký.');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.logout();
    await repository.client.cancelActiveRequests();
    user = null;
    error = null;
    notifyListeners();
  }

  Future<void> handleSessionExpired() async {
    await repository.storage.clearSession();
    await repository.client.cancelActiveRequests();
    user = null;
    error = 'Phiên đăng nhập đã hết hạn';
    notifyListeners();
  }

  void clearError() {
    if (error == null) return;
    error = null;
    notifyListeners();
  }

  static String _message(Object exception, String fallback) {
    if (exception is DioException) {
      final data = exception.response?.data;
      if (data is Map<String, dynamic> && data['message'] is String) {
        return data['message'] as String;
      }
    }
    final message = exception.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message.isEmpty
        ? fallback
        : message;
  }
}
