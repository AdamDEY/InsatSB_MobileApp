import 'package:flutter/material.dart';
import '../../services/firestore_auth_provider.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  LoginViewModel(this._authProvider);
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;
  
  String? _emailError;
  String? get emailError => _emailError;
  
  String? _passwordError;
  String? get passwordError => _passwordError;
  
  bool get isLoading => _authProvider.isLoading;
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  bool _validatePassword(String password) {
    return password.length >= 6;
  }
  
  void _clearErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }
  
  Future<bool> login() async {
    _clearErrors();
    
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    // Validate email
    if (email.isEmpty) {
      _emailError = 'Email is required';
      notifyListeners();
      return false;
    } else if (!_validateEmail(email)) {
      _emailError = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    
    // Validate password
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      notifyListeners();
      return false;
    } else if (!_validatePassword(password)) {
      _passwordError = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }
    
    try {
      final success = await _authProvider.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (!success && _authProvider.errorMessage != null) {
        // Handle Firebase Auth errors
        final error = _authProvider.errorMessage!;
        if (error.contains('email')) {
          _emailError = error;
        } else if (error.contains('password')) {
          _passwordError = error;
        } else {
          _emailError = error;
        }
        notifyListeners();
      }
      
      return success;
      
    } catch (e) {
      _emailError = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }
  
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    _clearErrors();
  }
}
