import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import '../../../core/booking/booking_store.dart';
import '../../../core/theme/app_colors.dart';
import 'payment_screen.dart';

class BookingSlotsScreen extends StatelessWidget {
  const BookingSlotsScreen({
    super.key,
    required this.therapistId,
    required this.patientId,
    required this.patientName,
    required this.type,
  });

  final String therapistId;
  final String patientId;
  final String patientName;
  final SessionType type;

  String _formatSlot(BuildContext context, DateTime dt) {
    final date =
        "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    final t = TimeOfDay.fromDateTime(dt).format(context);
    return "$date • $t";
  }

  @override
  Widget build(BuildContext context) {
    final slots = BookingStore.instance.getAvailableSlots(therapistId, type);

    return Scaffold(
      appBar: AppBar(title: const Text("Choose date & time")),
      body: slots.isEmpty
          ? const Center(
        child: Text(
          "No available slots right now.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: slots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = slots[i];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    therapistId: therapistId,
                    patientId: patientId,
                    patientName: patientName,
                    type: type,
                    slot: s,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatSlot(context, s.start),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
