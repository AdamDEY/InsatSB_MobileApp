import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;
  
  String? _emailError;
  String? get emailError => _emailError;
  
  String? _passwordError;
  String? get passwordError => _passwordError;
  
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
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock login logic - in a real app, you would call an API
      if (email == 'ieee@example.com' && password == 'password123') {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loginWithCallback(Function(bool success) onComplete) async {
    final success = await login();
    onComplete(success);
  }
  
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    _clearErrors();
  }
}
