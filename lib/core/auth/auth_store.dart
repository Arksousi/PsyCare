import 'auth_models.dart';
import '../models/user_role.dart';

class AuthResult {
  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;

  final AppUser? user;
  final String? error;

  bool get isSuccess => user != null;
}

class AuthStore {
  AuthStore._();

  static final AuthStore instance = AuthStore._();

  final Map<String, AppUser> _usersByEmail = {};

  void seedDemoAccountsIfEmpty() {
    if (_usersByEmail.isNotEmpty) return;

    // Demo accounts for quick testing.
    signUp(
      role: UserRole.therapist,
      displayName: "Demo Therapist",
      email: "therapist@psycare.app",
      password: "123456",
    );
    signUp(
      role: UserRole.patient,
      displayName: "Demo Patient",
      email: "patient@psycare.app",
      password: "123456",
    );
  }

  AuthResult signUp({
    required UserRole role,
    required String displayName,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return const AuthResult.failure("Email is required.");
    }
    if (_usersByEmail.containsKey(normalizedEmail)) {
      return const AuthResult.failure("An account with this email already exists.");
    }

    final user = AppUser(
      role: role,
      displayName: displayName.trim().isEmpty ? role.label : displayName.trim(),
      email: normalizedEmail,
      password: password,
    );

    _usersByEmail[normalizedEmail] = user;
    return AuthResult.success(user);
  }

  AuthResult login({
    required UserRole role,
    required String email,
    required String password,
  }) {
    seedDemoAccountsIfEmpty();

    final normalizedEmail = email.trim().toLowerCase();

    // ✅ Admin can login from ANY role screen
    const adminEmail = "admin@psycare.app";
    const adminPass = "admin1234";

    if (normalizedEmail == adminEmail && password == adminPass) {
      final adminUser = AppUser(
        role: UserRole.admin,
        displayName: "Admin",
        email: adminEmail,
        password: adminPass,
      );
      return AuthResult.success(adminUser);
    }

    final user = _usersByEmail[normalizedEmail];

    if (user == null) {
      return const AuthResult.failure("No account found for this email.");
    }
    if (user.role != role) {
      return AuthResult.failure("This account is registered as ${user.role.label}, not ${role.label}.");
    }
    if (user.password != password) {
      return const AuthResult.failure("Incorrect password.");
    }

    return AuthResult.success(user);
  }
}
