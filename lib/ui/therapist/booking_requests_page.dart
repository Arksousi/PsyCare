import 'package:flutter/material.dart';
import '../../service/booking_service.dart';
import '../../service/auth_service.dart';

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({super.key});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  final _bookingService = BookingService();
  bool _busy = false;
  late Future<List<dynamic>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() {
    setState(() {
      _requestsFuture = _bookingService.getMyBookings().then((bookings) {
        return bookings.where((b) => b['status'] == 'pending').toList();
      });
    });
  }

  Future<void> _accept(String bookingId) async {
    setState(() => _busy = true);
    try {
      await _bookingService.therapistAcceptBooking(bookingId: bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted ✅')));
      _fetchRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accept failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(String bookingId) async {
    setState(() => _busy = true);
    try {
      await _bookingService.therapistRejectBooking(bookingId: bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected ✅')));
      _fetchRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reject failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatRange(String startStr, String endStr) {
    final s = DateTime.parse(startStr).toLocal();
    final e = DateTime.parse(endStr).toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    final date = '${s.year}-${two(s.month)}-${two(s.day)}';
    final start = '${two(s.hour)}:${two(s.minute)}';
    final end = '${two(e.hour)}:${two(e.minute)}';
    return '$date • $start - $end';
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService().currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRequests),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _requestsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final docs = snap.data ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No pending requests.'));
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = docs[i];

                    final patientInfo = d['patientId'] is Map 
                        ? d['patientId']['fullName'] 
                        : (d['patientId'] ?? '');
                        
                    final startAt = d['startAt'];
                    final endAt = d['endAt'];

                    final timeLabel = (startAt != null && endAt != null)
                        ? _formatRange(startAt, endAt)
                        : 'Time unknown';

                    return ListTile(
                      title: Text(timeLabel),
                      subtitle: Text('Patient: $patientInfo'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _busy ? null : () => _reject(d['_id']),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _busy ? null : () => _accept(d['_id']),
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
