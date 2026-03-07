import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/booking_service.dart';

class SlotsPage extends StatelessWidget {
  const SlotsPage({super.key, required this.therapistId});
  final String therapistId;

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('therapistSlots')
        .where('therapistId', isEqualTo: therapistId)
        .where('status', isEqualTo: 'available')
        .orderBy('startAt');

    return Scaffold(
      appBar: AppBar(title: const Text('Available Slots')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No available slots'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final start = (d['startAt'] as Timestamp).toDate();
              final end = (d['endAt'] as Timestamp).toDate();
              final label =
                  '${DateFormat('EEE, MMM d').format(start)} • ${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';

              final bookingService = BookingService();

              return ListTile(
                title: Text(label),
                trailing: ElevatedButton(
                  onPressed: () async {
                    try {
                      final bookingId = await bookingService.bookSlot(
                        slotId: docs[i].id,
                      );

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booked ✅ (ID: $bookingId)')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                    }
                  },
                  child: const Text('Book'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
