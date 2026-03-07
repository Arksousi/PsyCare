import '../models/user_role.dart';

class AppUser {
  const AppUser({
    required this.role,
    required this.displayName,
    required this.email,
    required this.password,
  });

  final UserRole role;
  final String displayName;
  final String email;
  final String password;
//Hi
  AppUser copyWith({
    UserRole? role,
    String? displayName,
    String? email,
    String? password,
  }) {
    return AppUser(
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
