import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../service/booking_service.dart';

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({super.key});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  final _bookingService = BookingService();
  bool _cleanedUp = false;
  bool _busy = false;

  User? get _me => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _runCleanupOnce();
  }

  Future<void> _runCleanupOnce() async {
    // Option B (this semester): expire old reservations when therapist opens the page
    try {
      await _bookingService.cleanupExpiredReservations(limit: 30);
    } catch (_) {
      // Ignore cleanup errors (don't block UI)
    } finally {
      if (mounted) setState(() => _cleanedUp = true);
    }
  }

  Future<void> _accept(String bookingId) async {
    setState(() => _busy = true);
    try {
      await _bookingService.therapistAcceptBooking(bookingId: bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Accepted ✅')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Accept failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(String bookingId) async {
    setState(() => _busy = true);
    try {
      await _bookingService.therapistRejectBooking(bookingId: bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rejected ✅')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reject failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatRange(Timestamp startTs, Timestamp endTs) {
    final s = startTs.toDate();
    final e = endTs.toDate();
    String two(int x) => x.toString().padLeft(2, '0');
    final date = '${s.year}-${two(s.month)}-${two(s.day)}';
    final start = '${two(s.hour)}:${two(s.minute)}';
    final end = '${two(e.hour)}:${two(e.minute)}';
    return '$date • $start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    if (me == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final q = FirebaseFirestore.instance
        .collection('bookings')
        .where('therapistId', isEqualTo: me.uid)
        .where(
          'status',
          isEqualTo: 'pending',
        ) // matches your BookingStatus.pending
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: Column(
        children: [
          if (!_cleanedUp)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Checking expired reservations...'),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: q.snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No pending requests.'));
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final d = doc.data();

                    final patientId = (d['patientId'] as String?) ?? '';
                    final startAt = d['startAt'] as Timestamp?;
                    final endAt = d['endAt'] as Timestamp?;

                    final timeLabel = (startAt != null && endAt != null)
                        ? _formatRange(startAt, endAt)
                        : 'Time unknown';

                    return ListTile(
                      title: Text(timeLabel),
                      subtitle: Text('Patient: $patientId'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _busy ? null : () => _reject(doc.id),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _busy ? null : () => _accept(doc.id),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
