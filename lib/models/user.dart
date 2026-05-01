enum UserRole {
  member('member'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'member':
        return UserRole.member;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Member';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isMember => this == UserRole.member;
}

class AppUser {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final isAdmin = json['isAdmin'] == true;
    final roleValue = json['role'] as String?;
    final role = isAdmin
        ? UserRole.admin
        : (roleValue != null
              ? UserRole.fromString(roleValue)
              : UserRole.member);

    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['fullName'] ?? '',
      role: role,
      createdAt: _parseTimestamp(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? _parseTimestamp(json['lastLoginAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }

    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }

    if (timestamp is DateTime) {
      return timestamp;
    }

    // Fallback to current time
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role.value,
      'isAdmin': role.isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
