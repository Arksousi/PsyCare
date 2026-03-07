import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import '../../../core/theme/app_colors.dart';
import 'booking_slots_screen.dart';

class BookingTypeScreen extends StatelessWidget {
  const BookingTypeScreen({
    super.key,
    required this.therapistId,
    required this.patientId,
    required this.patientName,
  });

  final String therapistId;
  final String patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose session type")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              title: "On-site session",
              subtitle: "Visit the therapist in person",
              icon: Icons.location_on_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingSlotsScreen(
                      therapistId: therapistId,
                      patientId: patientId,
                      patientName: patientName,
                      type: SessionType.onsite,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _card(
              title: "Video call",
              subtitle: "Online session by video",
              icon: Icons.videocam_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingSlotsScreen(
                      therapistId: therapistId,
                      patientId: patientId,
                      patientName: patientName,
                      type: SessionType.video,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
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
  }
}
