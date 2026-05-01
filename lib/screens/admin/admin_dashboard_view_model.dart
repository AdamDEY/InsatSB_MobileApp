import 'package:flutter/material.dart';
import '../../repositories/admin_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  int _totalUsers = 0;
  final int _totalEvents = 0;
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardViewModel(this._adminRepository);

  int get totalUsers => _totalUsers;
  int get totalEvents => _totalEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      final users = await _adminRepository.getAllUsers();
      _totalUsers = users.length;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load dashboard data: ${e.toString()}');
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
