enum UserRole { patient, therapist }

extension UserRoleX on UserRole {
  String get value => name; // "patient" or "therapist"

  static UserRole fromString(String s) {
    return UserRole.values.firstWhere(
          (e) => e.name == s,
      orElse: () => UserRole.patient,
    );
  }
}

enum SlotStatus { available, reserved, booked, cancelled }
extension SlotStatusX on SlotStatus {
  String get value => name;
  static SlotStatus fromString(String s) {
    return SlotStatus.values.firstWhere(
          (e) => e.name == s,
      orElse: () => SlotStatus.available,
    );
  }
}

enum BookingStatus { pending, accepted, rejected, cancelled }
extension BookingStatusX on BookingStatus {
  String get value => name;
  static BookingStatus fromString(String s) {
    return BookingStatus.values.firstWhere(
          (e) => e.name == s,
      orElse: () => BookingStatus.pending,
    );
  }
}
