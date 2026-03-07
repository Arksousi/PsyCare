import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/enums.dart';

class BookingService {
  BookingService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// Transaction-safe booking: prevents two patients booking the same slot.
  ///
  /// - Reads therapistSlots/{slotId}
  /// - Requires status == "available"
  /// - Creates bookings/{bookingId} (pending)
  /// - Updates slot to "reserved" and attaches patientId + bookingId
  /// - Creates notifications to therapist
  ///
  /// Throws [StateError] if slot is not available.
  Future<String> bookSlot({
    required String slotId,
  }) async {
    final patient = _auth.currentUser;
    if (patient == null) {
      throw StateError('Not authenticated.');
    }

    final slotRef = _db.collection('therapistSlots').doc(slotId);
    final bookingsRef = _db.collection('bookings').doc(); // auto-id
    final notifRef = _db.collection('notifications').doc();

    final bookingId = bookingsRef.id;

    await _db.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) {
        throw StateError('Slot not found.');
      }

      final slot = slotSnap.data() as Map<String, dynamic>;

      final statusStr = (slot['status'] as String?) ?? SlotStatus.available.value;
      final status = SlotStatusX.fromString(statusStr);

      if (status != SlotStatus.available) {
        throw StateError('This slot is not available anymore.');
      }

      final therapistId = slot['therapistId'] as String?;
      final startAt = slot['startAt'];
      final endAt = slot['endAt'];

      if (therapistId == null || startAt == null || endAt == null) {
        throw StateError('Slot data is incomplete.');
      }

      final now = FieldValue.serverTimestamp();

      // 1) Create booking doc
      tx.set(bookingsRef, {
        'therapistId': therapistId,
        'patientId': patient.uid,
        'slotId': slotId,
        'startAt': startAt,
        'endAt': endAt,
        'status': BookingStatus.pending.value,
        'createdAt': now,
        'updatedAt': now,
      });

      // 2) Update slot -> reserved
      tx.update(slotRef, {
        'status': SlotStatus.reserved.value,
        'patientId': patient.uid,
        'bookingId': bookingId,
        'reservedUntil': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 15)),
        ),
      });

      // 3) Create notification to therapist
      tx.set(notifRef, {
        'userId': therapistId,
        'type': 'booking_request',
        'title': 'New booking request',
        'body': 'A patient requested a session.',
        'bookingId': bookingId,
        'isRead': false,
        'createdAt': now,
      });
    });

    return bookingId;
  }

  /// Therapist accepts booking (also transaction-safe).
  /// - Only therapist should call this (enforce via security rules later)
  /// - booking: pending -> accepted
  /// - slot: reserved -> booked
  /// - notify patient
  Future<void> therapistAcceptBooking({
    required String bookingId,
  }) async {
    final therapist = _auth.currentUser;
    if (therapist == null) throw StateError('Not authenticated.');

    final bookingRef = _db.collection('bookings').doc(bookingId);
    final notifRef = _db.collection('notifications').doc();

    await _db.runTransaction((tx) async {
      final bookingSnap = await tx.get(bookingRef);
      if (!bookingSnap.exists) throw StateError('Booking not found.');

      final booking = bookingSnap.data() as Map<String, dynamic>;
      final statusStr = (booking['status'] as String?) ?? '';
      final status = BookingStatusX.fromString(statusStr);

      if (status != BookingStatus.pending) {
        throw StateError('Booking is not pending.');
      }

      final therapistId = booking['therapistId'] as String?;
      final patientId = booking['patientId'] as String?;
      final slotId = booking['slotId'] as String?;

      if (therapistId == null || patientId == null || slotId == null) {
        throw StateError('Booking data is incomplete.');
      }

      if (therapistId != therapist.uid) {
        throw StateError('Only the assigned therapist can accept.');
      }

      final slotRef = _db.collection('therapistSlots').doc(slotId);
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) throw StateError('Slot not found.');

      final slot = slotSnap.data() as Map<String, dynamic>;
      final slotStatus = SlotStatusX.fromString((slot['status'] as String?) ?? '');

      // Slot should be reserved and belong to this booking
      if (slotStatus != SlotStatus.reserved) {
        throw StateError('Slot is not reserved.');
      }
      if ((slot['bookingId'] as String?) != bookingId) {
        throw StateError('Slot bookingId mismatch.');
      }
      final reservedUntilTs = slot['reservedUntil'] as Timestamp?;
      if (reservedUntilTs != null && DateTime.now().isAfter(reservedUntilTs.toDate())) {
        throw StateError('Reservation expired. Cannot accept.');
      }
      final now = FieldValue.serverTimestamp();

      // Update booking -> accepted
      tx.update(bookingRef, {
        'status': BookingStatus.accepted.value,
        'updatedAt': now,
      });

      // Update slot -> booked
      tx.update(slotRef, {
        'status': SlotStatus.booked.value,
      });

      // Notify patient
      tx.set(notifRef, {
        'userId': patientId,
        'type': 'booking_accepted',
        'title': 'Booking accepted',
        'body': 'Your therapist accepted your session.',
        'bookingId': bookingId,
        'isRead': false,
        'createdAt': now,
      });
    });
  }

  /// Therapist rejects booking:
  /// - booking -> rejected
  /// - slot -> available (free again)
  /// - notify patient
  Future<void> therapistRejectBooking({
    required String bookingId,
  }) async {
    final therapist = _auth.currentUser;
    if (therapist == null) throw StateError('Not authenticated.');

    final bookingRef = _db.collection('bookings').doc(bookingId);
    final notifRef = _db.collection('notifications').doc();

    await _db.runTransaction((tx) async {
      final bookingSnap = await tx.get(bookingRef);
      if (!bookingSnap.exists) throw StateError('Booking not found.');

      final booking = bookingSnap.data() as Map<String, dynamic>;

      final therapistId = booking['therapistId'] as String?;
      final patientId = booking['patientId'] as String?;
      final slotId = booking['slotId'] as String?;

      if (therapistId == null || patientId == null || slotId == null) {
        throw StateError('Booking data is incomplete.');
      }
      if (therapistId != therapist.uid) {
        throw StateError('Only the assigned therapist can reject.');
      }

      final slotRef = _db.collection('therapistSlots').doc(slotId);
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) throw StateError('Slot not found.');

      final now = FieldValue.serverTimestamp();

      tx.update(bookingRef, {
        'status': BookingStatus.rejected.value,
        'updatedAt': now,
      });

      // Free the slot again
      tx.update(slotRef, {
        'status': SlotStatus.available.value,
        'patientId': null,
        'bookingId': null,
        'reservedUntil': null,
      });

      tx.set(notifRef, {
        'userId': patientId,
        'type': 'booking_rejected',
        'title': 'Booking rejected',
        'body': 'Your therapist rejected the session.',
        'bookingId': bookingId,
        'isRead': false,
        'createdAt': now,
      });
    });
  }
  /// Expires a reservation if reservedUntil has passed and booking is still pending.
  /// Transaction-safe: updates booking + slot + notifies patient.
  Future<void> expireReservationIfNeeded({
    required String bookingId,
  }) async {
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final notifRef = _db.collection('notifications').doc();

    await _db.runTransaction((tx) async {
      final bookingSnap = await tx.get(bookingRef);
      if (!bookingSnap.exists) return;

      final booking = bookingSnap.data() as Map<String, dynamic>;
      final statusStr = (booking['status'] as String?) ?? '';
      final status = BookingStatusX.fromString(statusStr);

      // Only expire if still pending (or pending_payment)
      if (status != BookingStatus.pending) return;

      final slotId = booking['slotId'] as String?;
      final patientId = booking['patientId'] as String?;
      if (slotId == null || patientId == null) return;

      final slotRef = _db.collection('therapistSlots').doc(slotId);
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) return;

      final slot = slotSnap.data() as Map<String, dynamic>;
      final slotStatus = SlotStatusX.fromString((slot['status'] as String?) ?? '');

      // Only expire reserved slots that match this booking
      if (slotStatus != SlotStatus.reserved) return;
      if ((slot['bookingId'] as String?) != bookingId) return;

      final reservedUntilTs = slot['reservedUntil'] as Timestamp?;
      if (reservedUntilTs == null) return;

      final now = DateTime.now();
      final reservedUntil = reservedUntilTs.toDate();

      if (now.isBefore(reservedUntil)) return; // not expired yet

      final serverNow = FieldValue.serverTimestamp();

      // booking -> expired
      tx.update(bookingRef, {
        'status': 'expired', // if your enum doesn't include expired yet
        'updatedAt': serverNow,
      });

      // slot -> available again
      tx.update(slotRef, {
        'status': SlotStatus.available.value,
        'patientId': null,
        'bookingId': null,
        'reservedUntil': null,
      });

      // notify patient
      tx.set(notifRef, {
        'userId': patientId,
        'type': 'booking_expired',
        'title': 'Reservation expired',
        'body': 'Your reservation expired because payment was not completed in time.',
        'bookingId': bookingId,
        'isRead': false,
        'createdAt': serverNow,
      });
    });
  }

  /// Simple cleanup: expire any reserved slots that are past reservedUntil.
  /// Call this when patient opens slots page OR therapist opens requests page.
  Future<void> cleanupExpiredReservations({
    int limit = 20,
  }) async {
    final nowTs = Timestamp.fromDate(DateTime.now());

    // Find expired reserved slots
    final q = await _db
        .collection('therapistSlots')
        .where('status', isEqualTo: SlotStatus.reserved.value)
        .where('reservedUntil', isLessThanOrEqualTo: nowTs)
        .limit(limit)
        .get();

    for (final doc in q.docs) {
      final data = doc.data();
      final bookingId = data['bookingId'] as String?;
      if (bookingId == null) continue;

      // Expire each booking safely (transaction will double-check)
      await expireReservationIfNeeded(bookingId: bookingId);
    }
  }
}
