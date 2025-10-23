import '../models/user.dart';

/// Utility class for role-based access control
/// This class provides methods to check user permissions and roles
class RoleBasedAccess {
  static const Map<UserRole, List<String>> _permissions = {
    UserRole.member: [
      'view_events',
      'register_events',
      'view_profile',
      'edit_profile',
    ],
    UserRole.admin: [
      'view_events',
      'register_events',
      'view_profile',
      'edit_profile',
      'manage_users',
      'manage_events',
      'view_analytics',
      'create_events',
      'delete_events',
      'moderate_content',
    ],
  };

  /// Check if a user role has a specific permission
  static bool hasPermission(UserRole role, String permission) {
    return _permissions[role]?.contains(permission) ?? false;
  }

  /// Get all permissions for a specific role
  static List<String> getPermissions(UserRole role) {
    return _permissions[role] ?? [];
  }

  /// Check if user can manage other users
  static bool canManageUsers(UserRole role) {
    return hasPermission(role, 'manage_users');
  }

  /// Check if user can manage events
  static bool canManageEvents(UserRole role) {
    return hasPermission(role, 'manage_events');
  }

  /// Check if user can view analytics
  static bool canViewAnalytics(UserRole role) {
    return hasPermission(role, 'view_analytics');
  }

  /// Check if user can create events
  static bool canCreateEvents(UserRole role) {
    return hasPermission(role, 'create_events');
  }

  /// Check if user can delete events
  static bool canDeleteEvents(UserRole role) {
    return hasPermission(role, 'delete_events');
  }

  /// Check if user can moderate content
  static bool canModerateContent(UserRole role) {
    return hasPermission(role, 'moderate_content');
  }

  /// Get role hierarchy level (higher number = more permissions)
  static int getRoleLevel(UserRole role) {
    switch (role) {
      case UserRole.member:
        return 1;
      case UserRole.admin:
        return 2;
    }
  }

  /// Check if one role has higher privileges than another
  static bool hasHigherPrivileges(UserRole role1, UserRole role2) {
    return getRoleLevel(role1) > getRoleLevel(role2);
  }
}
