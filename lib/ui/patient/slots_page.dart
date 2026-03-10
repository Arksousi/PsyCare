import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/booking_service.dart';

class SlotsPage extends StatefulWidget {
  const SlotsPage({super.key, required this.therapistId});
  final String therapistId;

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  final _bookingService = BookingService();
  late Future<List<dynamic>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  void _fetchSlots() {
    setState(() {
      _slotsFuture = _bookingService.getSlots(therapistId: widget.therapistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Slots'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchSlots),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _slotsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No available slots'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final start = DateTime.parse(d['startAt']).toLocal();
              final end = DateTime.parse(d['endAt']).toLocal();
              final label =
                  '${DateFormat('EEE, MMM d').format(start)} • ${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';

              return ListTile(
                title: Text(label),
                trailing: ElevatedButton(
                  onPressed: () async {
                    try {
                      final bookingId = await _bookingService.bookSlot(
                        slotId: d['_id'],
                      );

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booked ✅ (ID: $bookingId)')),
                      );
                      _fetchSlots(); // Refresh list to remove the slot
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $e')),
                      );
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
