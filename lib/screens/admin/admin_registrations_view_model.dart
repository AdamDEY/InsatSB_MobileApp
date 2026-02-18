import 'package:flutter/material.dart';
import '../../repositories/admin_repository.dart';

class AdminRegistrationsViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  List<Map<String, dynamic>> _registrations = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedEventId;

  AdminRegistrationsViewModel(this._adminRepository);

  List<Map<String, dynamic>> get registrations => _registrations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedEventId => _selectedEventId;

  Future<void> loadEventRegistrations(String eventId) async {
    _setLoading(true);
    _clearError();
    _selectedEventId = eventId;

    try {
      _registrations = await _adminRepository.getEventRegistrations(eventId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load registrations: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> removeUserRegistration(String eventId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _adminRepository.removeUserRegistration(eventId, userId);
      _registrations.removeWhere((reg) => reg['id'] == userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove registration: ${e.toString()}');
      _setLoading(false);
    }
  }

  void clear() {
    _registrations = [];
    _selectedEventId = null;
    notifyListeners();
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
