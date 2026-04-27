import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiClient {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _baseUrlKey = 'api_base_url';

  ApiClient({required String baseUrl, http.Client? httpClient})
    : _baseUrl = _normalizeBaseUrl(baseUrl),
      _httpClient = httpClient ?? http.Client();

  String _baseUrl;
  final http.Client _httpClient;
  String? _token;

  String get baseUrl => _baseUrl;

  /// Request timeout duration
  static const Duration _timeout = Duration(seconds: 15);

  /// Initialize by loading saved token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final savedBaseUrl = prefs.getString(_baseUrlKey);
    if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
      _baseUrl = _normalizeBaseUrl(savedBaseUrl);
    }
  }

  /// Set token and persist to SharedPreferences
  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  /// Get current token (from memory)
  String? getToken() {
    return _token;
  }

  /// Save user data to SharedPreferences
  Future<void> saveUserData(Map<String, dynamic>? userData) async {
    final prefs = await SharedPreferences.getInstance();
    if (userData != null) {
      await prefs.setString(_userKey, jsonEncode(userData));
    } else {
      await prefs.remove(_userKey);
    }
  }

  /// Load user data from SharedPreferences
  Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userKey);
    if (userDataJson != null) {
      try {
        return jsonDecode(userDataJson) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Clear all stored data (on logout)
  Future<void> clear() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_token!}';
    }
    return headers;
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    return _requestWithFailover((baseUrl) async {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl$path'), headers: _headers())
          .timeout(_timeout);
      return _decodeJson(response);
    });
  }

  Future<List<dynamic>> getList(String path) async {
    return _requestWithFailover((baseUrl) async {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl$path'), headers: _headers())
          .timeout(_timeout);
      return _decodeList(response);
    });
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _requestWithFailover((baseUrl) async {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decodeJson(response);
    });
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _requestWithFailover((baseUrl) async {
      final response = await _httpClient
          .put(
            Uri.parse('$baseUrl$path'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decodeJson(response);
    });
  }

  Future<void> delete(String path) async {
    await _requestWithFailover((baseUrl) async {
      final response = await _httpClient
          .delete(Uri.parse('$baseUrl$path'), headers: _headers())
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, response.body);
      }
    });
  }

  Future<T> _requestWithFailover<T>(
    Future<T> Function(String baseUrl) operation,
  ) async {
    final candidates = _buildCandidateBaseUrls();

    Object? lastConnectivityError;
    StackTrace? lastConnectivityStackTrace;

    for (final candidate in candidates) {
      try {
        final result = await operation(candidate);
        if (candidate != _baseUrl) {
          _baseUrl = candidate;
          await _persistBaseUrl(candidate);
        }
        return result;
      } on TimeoutException catch (e, st) {
        lastConnectivityError = e;
        lastConnectivityStackTrace = st;
      } on http.ClientException catch (e, st) {
        lastConnectivityError = e;
        lastConnectivityStackTrace = st;
      }
    }

    if (lastConnectivityError != null) {
      Error.throwWithStackTrace(
        lastConnectivityError,
        lastConnectivityStackTrace ?? StackTrace.current,
      );
    }

    throw TimeoutException('No reachable backend base URL candidate.');
  }

  List<String> _buildCandidateBaseUrls() {
    final result = <String>[];
    final seen = <String>{};

    void addCandidate(String value) {
      final normalized = _normalizeBaseUrl(value);
      if (normalized.isNotEmpty && seen.add(normalized)) {
        result.add(normalized);
      }
    }

    addCandidate(_baseUrl);
    for (final candidate in ApiConfig.candidateBaseUrls) {
      addCandidate(candidate);
    }

    return result;
  }

  Future<void> _persistBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _normalizeBaseUrl(value));
  }

  static String _normalizeBaseUrl(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException(response.statusCode, 'Unexpected response format');
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) {
      return <dynamic>[];
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw ApiException(response.statusCode, 'Unexpected response format');
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
