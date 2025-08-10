enum UserRole { parent, caretaker, admin }

class AppUser {
  final int id;
  final String email;
  final String name;
  final String username;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.parent,
      ),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'role': role.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  AppUser copyWith({
    int? id,
    String? email,
    String? name,
    String? username,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.parent:
        return 'Orangtua';
      case UserRole.caretaker:
        return 'Pengasuh';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  String toString() {
    return 'AppUser(id: $id, username: $username, name: $name, role: $role)';
  }
}

class AuthData {
  final AppUser user;
  final String token;

  AuthData({required this.user, required this.token});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: AppUser.fromJson(json['user']),
      token: json['token'],
    );
  }
}
