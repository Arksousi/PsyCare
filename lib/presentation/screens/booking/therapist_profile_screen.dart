import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import '../../../core/booking/booking_store.dart';
import '../../../core/chat/store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../chat/chat_list_screen.dart';
import 'booking_type_screen.dart';

class TherapistProfileScreen extends StatelessWidget {
  const TherapistProfileScreen({
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

  @override
  Widget build(BuildContext context) {
    final therapist = BookingStore.instance.therapistById(therapistId);

    return Scaffold(
      appBar: AppBar(title: const Text("Therapist Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(therapist),
          const SizedBox(height: 14),

          _infoCard(
            title: "Contact",
            children: [
              _row("Phone", therapist.phoneNumber),
              const SizedBox(height: 8),
              _row("Location", therapist.locationText),
              const SizedBox(height: 8),
              _linkRow("Maps link", therapist.locationUrl),
            ],
          ),

          const SizedBox(height: 12),

          _infoCard(
            title: "Qualifications",
            children: therapist.qualifications
                .map(
                  (q) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "• $q",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            )
                .toList(),
          ),

          const SizedBox(height: 12),

          _infoCard(
            title: "Prices",
            children: [
              _row("On-site", "\$${therapist.priceOnsite}"),
              const SizedBox(height: 8),
              _row("Video call", "\$${therapist.priceVideo}"),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "Chat",
                  isSecondary: true,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () {
                    final store = ChatStore.instance;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatListScreen(
                          currentUserId: patientId,
                          currentUserName: patientName,
                          otherUserId: store.demoTherapistId,
                          otherUserName: "Therapist",
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: "Book now",
                  icon: Icons.calendar_month_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingTypeScreen(
                          therapistId: therapistId,
                          patientId: patientId,
                          patientName: patientName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header(TherapistProfile t) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${t.locationText} • ⭐ ${t.rating} (${t.ratingCount})",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
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
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String a, String b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            a,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            b,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _linkRow(String a, String url) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            a,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            url,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              height: 1.25,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
