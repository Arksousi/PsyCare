import 'package:flutter/material.dart';
import '../../service/booking_service.dart';
import '../../service/auth_service.dart';

class CreateSlotPage extends StatefulWidget {
  const CreateSlotPage({super.key});

  @override
  State<CreateSlotPage> createState() => _CreateSlotPageState();
}

class _CreateSlotPageState extends State<CreateSlotPage> {
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;

  bool _loading = false;
  String? _error;

  final _bookingService = BookingService();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      initialDate: _date ?? now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _end ?? const TimeOfDay(hour: 10, minute: 30),
    );
    if (picked != null) setState(() => _end = picked);
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _createSlot() async {
    final user = AuthService().currentUser;
    if (user == null) {
      setState(() => _error = 'Not logged in.');
      return;
    }
    if (_date == null || _start == null || _end == null) {
      setState(() => _error = 'Pick date, start time, and end time.');
      return;
    }

    final startAt = _combine(_date!, _start!);
    final endAt = _combine(_date!, _end!);

    if (!endAt.isAfter(startAt)) {
      setState(() => _error = 'End time must be after start time.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _bookingService.createSlot(startAt, endAt);

      if (!mounted) return;
      Navigator.pop(context); // back to therapist home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot created ✅')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Pick date';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _fmtTime(TimeOfDay? t) {
    if (t == null) return 'Pick time';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Slot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(_fmtDate(_date)),
              leading: const Icon(Icons.calendar_month),
              onTap: _loading ? null : _pickDate,
            ),
            ListTile(
              title: Text('Start: ${_fmtTime(_start)}'),
              leading: const Icon(Icons.schedule),
              onTap: _loading ? null : _pickStart,
            ),
            ListTile(
              title: Text('End: ${_fmtTime(_end)}'),
              leading: const Icon(Icons.schedule_outlined),
              onTap: _loading ? null : _pickEnd,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _createSlot,
                child: _loading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create Slot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
