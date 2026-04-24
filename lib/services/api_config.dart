import 'package:flutter/foundation.dart';

class ApiConfig {
  // Preferred: pass API_BASE_URL via --dart-define for each environment.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:5000';
  static const String _defaultLocalhostBaseUrl = 'http://localhost:5000';

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // Android emulator must use host loopback alias instead of localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorBaseUrl;
    }

    return _defaultLocalhostBaseUrl;
  }
}
