enum UserRole { admin, therapist, patient }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return "Admin";
      case UserRole.therapist:
        return "Therapist";
      case UserRole.patient:
        return "Patient";
    }
  }
}
