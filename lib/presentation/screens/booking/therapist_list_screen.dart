import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import '../../../core/booking/booking_store.dart';
import '../../../core/theme/app_colors.dart';
import 'therapist_profile_screen.dart';

class TherapistListScreen extends StatelessWidget {
  const TherapistListScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.type,
  });

  final String patientId;
  final String patientName;
  final SessionType type;

  @override
  Widget build(BuildContext context) {
    final list = BookingStore.instance.getTherapists();

    return Scaffold(
      appBar: AppBar(title: const Text("Therapists")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final TherapistProfile t = list[i];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TherapistProfileScreen(
                    therapistId: t.id,
                    patientId: patientId,
                    patientName: patientName,
                    type: type,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryTeal.withOpacity(0.12),
                    child: Text(
                      t.name.isNotEmpty ? t.name[0].toUpperCase() : "T",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${t.locationText} • ⭐ ${t.rating} (${t.ratingCount})",
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
        },
      ),
    );
  }
}
