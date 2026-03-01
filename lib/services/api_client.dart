import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;
  String? _token;

  /// Request timeout duration
  static const Duration _timeout = Duration(seconds: 15);

  /// Initialize by loading saved token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
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
    final response = await _httpClient
        .get(Uri.parse('$baseUrl$path'), headers: _headers())
        .timeout(_timeout);
    return _decodeJson(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _httpClient
        .get(Uri.parse('$baseUrl$path'), headers: _headers())
        .timeout(_timeout);
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers(),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient
        .put(
          Uri.parse('$baseUrl$path'),
          headers: _headers(),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _decodeJson(response);
  }

  Future<void> delete(String path) async {
    final response = await _httpClient
        .delete(Uri.parse('$baseUrl$path'), headers: _headers())
        .timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
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
