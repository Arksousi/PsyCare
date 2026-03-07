enum SessionType { onsite, video }

enum PaymentMethod { visa, cliq, cash }

enum BookingStatus { pending, confirmed, rejected, cancelled, completed }

class TherapistProfile {
  final String id;
  final String name;
  final double rating;
  final int ratingCount;
  final String locationText; // "Jordan, Amman"
  final String phoneNumber;
  final String locationUrl; // link
  final List<String> qualifications;
  final int priceOnsite;
  final int priceVideo;

  const TherapistProfile({
    required this.id,
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.locationText,
    required this.phoneNumber,
    required this.locationUrl,
    required this.qualifications,
    required this.priceOnsite,
    required this.priceVideo,
  });
}

class BookingSlot {
  final DateTime start;
  const BookingSlot(this.start);
  String get id => start.toIso8601String();
}

class Booking {
  final String id;
  final String patientId;
  final String patientName;
  final String therapistId;
  final String therapistName;
  final SessionType type;
  final BookingSlot slot;
  final PaymentMethod paymentMethod;
  final int price;
  final DateTime createdAt;
  BookingStatus status;

  Booking({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.therapistId,
    required this.therapistName,
    required this.type,
    required this.slot,
    required this.paymentMethod,
    required this.price,
    required this.createdAt,
    required this.status,
  });
}
