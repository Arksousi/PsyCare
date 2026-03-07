import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'therapist_detail_page.dart';

class TherapistListPage extends StatelessWidget {
  const TherapistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance.collection('therapists');

    return Scaffold(
      appBar: AppBar(title: const Text('Therapists')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No therapists yet'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['fullName'] ?? 'Unknown'),
                subtitle: Text(data['locationText'] ?? ''),
                trailing: Text(
                  '${(data['ratingAvg'] ?? 0).toString()} ★',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TherapistDetailPage(
                        therapistId: d.id,
                        therapistData: data,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
