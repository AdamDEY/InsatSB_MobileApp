import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  
  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._userRepository) {
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

  void _init() {
    // For now, we'll start without a user
    // In a real app, you might want to store login state locally
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('AuthProvider: Attempting to sign in with email: $email');
      
      // Get user from Firestore
      final user = await _userRepository.getUserByEmail(email);
      
      if (user == null) {
        _setError('No user found with this email address');
        _setLoading(false);
        return false;
      }
      
      if (!user.isActive) {
        _setError('This account has been deactivated');
        _setLoading(false);
        return false;
      }
      
      // Check password (in production, this should be hashed)
      if (user.password != password) {
        print('AuthProvider: Password mismatch for user: ${user.email}');
        _setError('Invalid password');
        _setLoading(false);
        return false;
      }
      
      // Update last login
      await _userRepository.updateLastLogin(user.id);
      
      // Set current user
      _user = user.copyWith(lastLoginAt: DateTime.now());
      _setLoading(false);
      notifyListeners();
      
      print('AuthProvider: Successfully signed in user: ${user.fullName}');
      return true;
      
    } catch (e) {
      print('AuthProvider: Error during sign in: $e');
      _setError('An unexpected error occurred. Please try again.');
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
      print('AuthProvider: Attempting to create user with email: $email');
      
      // Check if user already exists
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        _setError('A user with this email already exists');
        _setLoading(false);
        return false;
      }
      
      // Create new user
      final newUser = AppUser(
        id: '', // Firestore will generate the ID
        email: email.toLowerCase(),
        password: password, // In production, hash this
        fullName: fullName,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      // Save to Firestore
      final success = await _userRepository.createUser(newUser);
      
      if (success) {
        // Get the created user with the generated ID
        final createdUser = await _userRepository.getUserByEmail(email);
        if (createdUser != null) {
          _user = createdUser;
          _setLoading(false);
          notifyListeners();
          print('AuthProvider: Successfully created user: ${createdUser.fullName}');
          return true;
        }
      }
      
      _setError('Failed to create user account');
      _setLoading(false);
      return false;
      
    } catch (e) {
      print('AuthProvider: Error during user creation: $e');
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      print('AuthProvider: Signing out user');
      _user = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('AuthProvider: Error during sign out: $e');
      _setError('An unexpected error occurred during sign out.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      print('AuthProvider: Attempting to send password reset for: $email');
      
      // Check if user exists
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        _setError('No user found with this email address');
        _setLoading(false);
        return false;
      }
      
      // In a real app, you would send an email here
      // For now, we'll just simulate success
      print('AuthProvider: Password reset email would be sent to: $email');
      _setLoading(false);
      return true;
      
    } catch (e) {
      print('AuthProvider: Error sending password reset: $e');
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
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
