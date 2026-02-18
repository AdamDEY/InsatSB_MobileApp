import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../repositories/admin_repository.dart';

class AdminUsersViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  List<AppUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  AppUser? _selectedUser;

  AdminUsersViewModel(this._adminRepository);

  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppUser? get selectedUser => _selectedUser;

  Future<void> loadUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _users = await _adminRepository.getAllUsers();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load users: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> updateUserRole(String userId, bool isAdmin) async {
    _setLoading(true);
    _clearError();

    try {
      await _adminRepository.updateUserRole(userId, isAdmin);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        // Update local user
        final userToUpdate = _users[index];
        _users[index] = AppUser(
          id: userToUpdate.id,
          email: userToUpdate.email,
          password: userToUpdate.password,
          fullName: userToUpdate.fullName,
          role: isAdmin ? UserRole.admin : UserRole.member,
          createdAt: userToUpdate.createdAt,
          lastLoginAt: userToUpdate.lastLoginAt,
          isActive: userToUpdate.isActive,
        );
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update user role: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _adminRepository.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete user: ${e.toString()}');
      _setLoading(false);
    }
  }

  void selectUser(AppUser user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelection() {
    _selectedUser = null;
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
