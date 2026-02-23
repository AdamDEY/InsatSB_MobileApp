import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  AuthProvider(this._apiClient) {
    _init();
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;
  String? get userEmail => _user?.email;
  String? get userId => _user?.id;
  String? get userFullName => _user?.fullName;
  UserRole? get userRole => _user?.role;

  // Role-based access methods
  bool get isAdmin => _user?.role.isAdmin ?? false;
  bool get isMember => _user?.role.isMember ?? false;

  // Check if user has specific role
  bool hasRole(UserRole role) => _user?.role == role;

  // Check if user can perform admin actions
  bool canManageUsers() => isAdmin;
  bool canManageEvents() => isAdmin;
  bool canViewAnalytics() => isAdmin;

  Future<void> _refreshCurrentUser() async {
    final userJson = await _apiClient.getJson('/api/users/me');
    _user = AppUser.fromJson(userJson);
    await _apiClient.saveUserData(userJson);
  }

  void _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize API client and load token from storage
      await _apiClient.init();

      // Try to restore user session from saved data
      final savedUserData = await _apiClient.loadUserData();
      print('DEBUG: Saved user data: $savedUserData'); // ADD THIS
      print('DEBUG: Token: ${_apiClient.getToken()}'); // ADD THIS
      if (savedUserData != null && _apiClient.getToken() != null) {
        try {
          // Validate token with backend
          final isValid = await validateToken();
          print('DEBUG: Token valid: $isValid'); // ADD THIS

          if (isValid) {
            try {
              await _refreshCurrentUser();
            } catch (_) {
              _user = AppUser.fromJson(savedUserData);
            }
            _isLoading = false;
            notifyListeners();
            return;
          }
        } catch (_) {
          // Saved user data is invalid, clear it
          await _apiClient.clear();
        }
      }

      _isLoading = false;
    } catch (_) {
      _isLoading = false;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiClient.postJson('/api/auth/login', {
        'email': email,
        'password': password,
      });

      final token = response['token'] as String?;
      final userJson = response['user'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty || userJson == null) {
        _setError('Invalid login response from server.');
        _setLoading(false);
        return false;
      }

      await _apiClient.setToken(token);
      try {
        await _refreshCurrentUser();
      } catch (_) {
        await _apiClient.saveUserData(userJson);
        _user = AppUser.fromJson(userJson);
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Login failed. Please check your credentials.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.member,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiClient.postJson('/api/auth/register', {
        'email': email,
        'password': password,
        'fullName': fullName,
      });

      final token = response['token'] as String?;
      final userJson = response['user'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty || userJson == null) {
        _setError('Invalid registration response from server.');
        _setLoading(false);
        return false;
      }

      await _apiClient.setToken(token);
      try {
        await _refreshCurrentUser();
      } catch (_) {
        await _apiClient.saveUserData(userJson);
        _user = AppUser.fromJson(userJson);
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _apiClient.postJson('/api/auth/logout', <String, dynamic>{});
    } catch (_) {
      // Ignore logout failures; clear local session anyway.
    }

    await _apiClient.clear();
    _user = null;
    _setLoading(false);
    notifyListeners();
    return true;
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _clearError();

    _setError('Password reset is not implemented on the backend yet.');
    _setLoading(false);
    return false;
  }

  /// Validate if the stored token is still valid by calling backend
  Future<bool> validateToken() async {
    if (_apiClient.getToken() == null) {
      await _apiClient.clear();
      _user = null;
      notifyListeners();
      return false;
    }

    try {
      await _apiClient.getJson('/api/auth/validate');
      return true;
    } catch (e) {
      // Token is expired or invalid, clear session
      await _apiClient.clear();
      _user = null;
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
