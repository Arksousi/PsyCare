import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import 'booking_slots_firestore_screen.dart';

class TherapistsFirestoreScreen extends StatelessWidget {
  const TherapistsFirestoreScreen({
    super.key,
    required this.type,
    required this.patientId,
    required this.patientName,
  });

  final SessionType type;
  final String patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('therapists')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Therapist")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No therapists yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final doc = docs[i];
              final data = doc.data();

              final therapistId = doc.id;
              final fullName = (data['fullName'] as String?) ?? "Therapist";
              final ratingAvg = (data['ratingAvg'] as num?)?.toDouble() ?? 0.0;
              final ratingCount = (data['ratingCount'] as num?)?.toInt() ?? 0;
              final locationText = (data['locationText'] as String?) ?? "";

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingSlotsFirestoreScreen(
                        therapistId: therapistId,
                        therapistName: fullName,
                        patientId: patientId,
                        patientName: patientName,
                        type: type,
                      ),
                    ),
                  );
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
                      const Icon(Icons.medical_services_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locationText.isEmpty
                                  ? 'Rating: ${ratingAvg.toStringAsFixed(1)} ($ratingCount)'
                                  : '$locationText • ${ratingAvg.toStringAsFixed(1)} ($ratingCount)',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
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
