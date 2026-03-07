  import 'dart:math';
  import 'booking_models.dart';
  
  import '../notifications/notification_store.dart';
  import '../notifications/notification_models.dart';
  
  class BookingStore {
    BookingStore._();
    static final BookingStore instance = BookingStore._();
  
    final List<TherapistProfile> _therapists = const [
      TherapistProfile(
        id: "t1",
        name: "Dr. Anas Al-Ayasrah",
        rating: 4.8,
        ratingCount: 214,
        locationText: "Jordan, Amman",
        phoneNumber: "+962 7X XXX XXXX",
        locationUrl: "https://maps.google.com",
        qualifications: [
          "PhD Clinical Psychology",
          "CBT Certified",
          "10+ years experience",
        ],
        priceOnsite: 35,
        priceVideo: 25,
      ),
      TherapistProfile(
        id: "t2",
        name: "Dr. Lo'ay Al-Alawneh",
        rating: 4.6,
        ratingCount: 167,
        locationText: "Jordan, Amman",
        phoneNumber: "+962 7X XXX XXXX",
        locationUrl: "https://maps.google.com",
        qualifications: [
          "MSc Counseling",
          "Trauma-informed therapy",
          "8+ years experience",
        ],
        priceOnsite: 30,
        priceVideo: 22,
      ),
    ];
  
    final List<Booking> _bookings = [];
  
    List<TherapistProfile> getTherapists() => List.unmodifiable(_therapists);
  
    TherapistProfile therapistById(String id) =>
        _therapists.firstWhere((t) => t.id == id);
  
    // Demo availability:
    List<BookingSlot> getAvailableSlots(String therapistId, SessionType type) {
      final now = DateTime.now();
      final hours = (type == SessionType.onsite) ? [10, 12, 15] : [11, 13, 17];
  
      final slots = <BookingSlot>[];
      for (int d = 0; d < 14; d++) {
        final day = DateTime(now.year, now.month, now.day).add(Duration(days: d));
        for (final h in hours) {
          final dt = DateTime(day.year, day.month, day.day, h, 0);
          if (dt.isAfter(now)) slots.add(BookingSlot(dt));
        }
      }
  
      final taken = _bookings
          .where((b) =>
      b.therapistId == therapistId &&
          (b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed))
          .map((b) => b.slot.id)
          .toSet();
  
      return slots.where((s) => !taken.contains(s.id)).toList();
    }
  
    List<Booking> bookingsForTherapist(String therapistId) {
      final list = _bookings.where((b) => b.therapistId == therapistId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  
    List<Booking> bookingsForPatient(String patientId) {
      final list = _bookings.where((b) => b.patientId == patientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  
    Booking createBooking({
      required String patientId,
      required String patientName,
      required String therapistId,
      required SessionType type,
      required BookingSlot slot,
      required PaymentMethod paymentMethod,
    }) {
      final therapist = therapistById(therapistId);
      final price = type == SessionType.onsite ? therapist.priceOnsite : therapist.priceVideo;
  
      final booking = Booking(
        id: _id("bk"),
        patientId: patientId,
        patientName: patientName,
        therapistId: therapistId,
        therapistName: therapist.name,
        type: type,
        slot: slot,
        paymentMethod: paymentMethod,
        price: price,
        createdAt: DateTime.now(),
        status: BookingStatus.pending,
      );
  
      _bookings.insert(0, booking);
  
      // ✅ notify therapist immediately when patient picks date/slot
      NotificationStore.instance.push(
        userId: therapistId,
        type: AppNotificationType.bookingRequest,
        title: "New booking request",
        message:
        "$patientName requested a ${type == SessionType.onsite ? "On-site" : "Video"} session on ${slot.start}.",
      );
  
      return booking;
    }
  
    void updateStatus(String bookingId, BookingStatus status) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx == -1) return;
      _bookings[idx].status = status;
    }
  
    String _id(String prefix) =>
        "${prefix}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}";
  }
