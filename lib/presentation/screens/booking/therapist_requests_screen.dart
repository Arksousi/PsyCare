import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import '../../../core/booking/booking_store.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_store.dart';
import '../../../core/theme/app_colors.dart';

class TherapistRequestsScreen extends StatefulWidget {
  const TherapistRequestsScreen({
    super.key,
    required this.therapistId,
  });

  final String therapistId;

  @override
  State<TherapistRequestsScreen> createState() => _TherapistRequestsScreenState();
}

class _TherapistRequestsScreenState extends State<TherapistRequestsScreen> {
  final bookingStore = BookingStore.instance;

  String _statusLabel(BookingStatus s) => s.name;

  String _formatSlot(BuildContext context, DateTime dt) {
    final date =
        "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    final time = TimeOfDay.fromDateTime(dt).format(context);
    return "$date • $time";
  }

  void _accept(Booking b) {
    bookingStore.updateStatus(b.id, BookingStatus.confirmed);

    // ✅ notify patient when therapist accepts
    NotificationStore.instance.push(
      userId: b.patientId,
      type: AppNotificationType.bookingConfirmed,
      title: "Booking confirmed ✅",
      message: "Your session is confirmed for ${b.slot.start} with ${b.therapistName}.",
    );

    setState(() {});
  }

  void _reject(Booking b) {
    bookingStore.updateStatus(b.id, BookingStatus.rejected);

    NotificationStore.instance.push(
      userId: b.patientId,
      type: AppNotificationType.bookingRejected,
      title: "Booking rejected",
      message: "Your booking request was rejected by ${b.therapistName}.",
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = bookingStore.bookingsForTherapist(widget.therapistId);

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Requests")),
      body: list.isEmpty
          ? const Center(
        child: Text(
          "No booking requests yet.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final b = list[i];

          final statusColor = b.status == BookingStatus.confirmed
              ? AppColors.primaryTeal
              : (b.status == BookingStatus.rejected
              ? AppColors.error
              : AppColors.textSecondary);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  "Type: ${b.type == SessionType.onsite ? "On-site" : "Video"}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  "Time: ${_formatSlot(context, b.slot.start)}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  "Payment: ${b.paymentMethod.name.toUpperCase()}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  "Price: \$${b.price}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text(
                      "Status: ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _statusLabel(b.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                if (b.status == BookingStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _accept(b),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Accept",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(b),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
