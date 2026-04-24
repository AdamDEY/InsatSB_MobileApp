import 'package:flutter/foundation.dart';

class ApiConfig {
  // Preferred: pass API_BASE_URL via --dart-define for each environment.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  // For physical Android devices over USB, use localhost with `adb reverse`.
  // For emulators, override with --dart-define=API_BASE_URL=http://10.0.2.2:5000.
  static const String _androidDevBaseUrl = 'http://localhost:5000';
  static const String _defaultLocalhostBaseUrl = 'http://localhost:5000';

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // Android uses localhost by default for USB debugging with adb reverse.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidDevBaseUrl;
    }

    return _defaultLocalhostBaseUrl;
  }
}
