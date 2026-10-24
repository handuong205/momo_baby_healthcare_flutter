import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl {
    // Flutter Web - Chrome
    if (kIsWeb) {
      return dotenv.env['WEB_API_URL'] ?? '';
    }

    // Android Emulator
    return dotenv.env['ANDROID_API_URL'] ?? '';
  }
}