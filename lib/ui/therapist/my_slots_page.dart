import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySlotsPage extends StatelessWidget {
  const MySlotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    final q = FirebaseFirestore.instance
        .collection('therapistSlots')
        .where('therapistId', isEqualTo: user.uid)
        .orderBy('startAt', descending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('My Slots')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No slots yet.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data();
              final start = (d['startAt'] as Timestamp).toDate();
              final end = (d['endAt'] as Timestamp).toDate();
              final status = (d['status'] as String?) ?? '';

              String two(int x) => x.toString().padLeft(2, '0');
              final label =
                  '${start.year}-${two(start.month)}-${two(start.day)}  ${two(start.hour)}:${two(start.minute)} → ${two(end.hour)}:${two(end.minute)}';

              return ListTile(
                title: Text(label),
                subtitle: Text('Status: $status'),
              );
            },
          );
        },
      ),
    );
  }
}
