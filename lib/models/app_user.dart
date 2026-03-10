class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String token;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.token = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'patient',
      token: json['token'] ?? '',
    );
  }
}
