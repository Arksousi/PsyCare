import 'package:flutter/material.dart';
import '../../service/booking_service.dart';
import '../../service/auth_service.dart';

class MySlotsPage extends StatefulWidget {
  const MySlotsPage({super.key});

  @override
  State<MySlotsPage> createState() => _MySlotsPageState();
}

class _MySlotsPageState extends State<MySlotsPage> {
  final _bookingService = BookingService();
  late Future<List<dynamic>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _slotsFuture = _bookingService.getMySlots();
  }

  void _refresh() {
    setState(() {
      _slotsFuture = _bookingService.getMySlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Slots'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _slotsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final slots = snap.data ?? [];
          if (slots.isEmpty) {
            return const Center(child: Text('No slots yet.'));
          }

          return ListView.separated(
            itemCount: slots.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = slots[i];
              final start = DateTime.parse(d['startAt']).toLocal();
              final end = DateTime.parse(d['endAt']).toLocal();
              final status = d['status'] ?? '';

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
