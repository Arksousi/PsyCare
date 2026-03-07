import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import 'package:psycare/service/booking_service.dart';
import 'booking_success_screen.dart';

class BookingSlotsFirestoreScreen extends StatelessWidget {
  const BookingSlotsFirestoreScreen({
    super.key,
    required this.therapistId,
    required this.therapistName,
    required this.patientId,
    required this.patientName,
    required this.type,
  });

  final String therapistId;
  final String therapistName;
  final String patientId;
  final String patientName;
  final SessionType type;

  String _fmt(Timestamp ts) {
    final d = ts.toDate();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('therapistSlots')
        .where('therapistId', isEqualTo: therapistId)
        .where('status', isEqualTo: 'available')
        .orderBy('startAt');

    return Scaffold(
      appBar: AppBar(title: const Text("Choose date & time")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No available slots right now."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data();

              final startAt = d['startAt'] as Timestamp?;
              final endAt = d['endAt'] as Timestamp?;
              final label = (startAt != null && endAt != null)
                  ? '${_fmt(startAt)} → ${_fmt(endAt)}'
                  : 'Unknown time';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  try {
                    final bookingId = await BookingService().bookSlot(
                      slotId: doc.id,
                    );

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingSuccessScreen(bookingId: bookingId),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking failed: $e')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded),
                      const SizedBox(width: 10),
                      Expanded(child: Text(label)),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
