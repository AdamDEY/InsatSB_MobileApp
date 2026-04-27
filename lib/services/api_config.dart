import 'package:flutter/foundation.dart';

class ApiConfig {
  // Preferred: pass API_BASE_URL via --dart-define for each environment.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  // Default Android URL for USB debugging with adb reverse.
  static const String _androidDevBaseUrl = 'http://localhost:5000';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:5000';
  static const String _androidUsbReverseBaseUrl = 'http://localhost:5000';
  static const String _defaultLocalhostBaseUrl = 'http://localhost:5000';

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _normalize(_envBaseUrl);
    }

    // Android physical devices cannot reach host machine via localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _normalize(_androidDevBaseUrl);
    }

    return _normalize(_defaultLocalhostBaseUrl);
  }

  static List<String> get candidateBaseUrls {
    if (_envBaseUrl.isNotEmpty) {
      return <String>[_normalize(_envBaseUrl)];
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _unique(<String>[
        _normalize(_androidUsbReverseBaseUrl),
        _normalize(_androidDevBaseUrl),
        _normalize(_androidEmulatorBaseUrl),
      ]);
    }

    return <String>[_normalize(_defaultLocalhostBaseUrl)];
  }

  static String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static List<String> _unique(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      if (seen.add(value)) {
        result.add(value);
      }
    }
    return result;
  }
}
