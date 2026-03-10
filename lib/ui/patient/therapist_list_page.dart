import 'package:flutter/material.dart';
import '../../service/therapist_service.dart';
import 'therapist_detail_page.dart';

class TherapistListPage extends StatefulWidget {
  const TherapistListPage({super.key});

  @override
  State<TherapistListPage> createState() => _TherapistListPageState();
}

class _TherapistListPageState extends State<TherapistListPage> {
  final _therapistService = TherapistService();
  late Future<List<dynamic>> _therapistsFuture;

  @override
  void initState() {
    super.initState();
    _fetchTherapists();
  }

  void _fetchTherapists() {
    setState(() {
      _therapistsFuture = _therapistService.getTherapists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapists'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTherapists),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _therapistsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No therapists yet'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final data = docs[i];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['fullName'] ?? 'Unknown'),
                subtitle: Text(data['locationText'] ?? ''),
                trailing: Text(
                  '${(data['ratingAvg'] ?? 0).toString()} ★',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // Adjust TherapistDetailPage to use standard Maps not DocumentSnapshot data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TherapistDetailPage(
                        therapistId: data['_id'],
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
