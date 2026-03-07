import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../booking/therapist_requests_screen.dart';
import '../therapist/therapist_inbox_screen.dart';
import 'home_widgets.dart';

class TherapistHomeScreen extends StatelessWidget {
  const TherapistHomeScreen({super.key, required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: AppColors.textPrimary,
    );

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            children: [
              GreetingCard(
                name: displayName,
                subtitle: "Role: Therapist • You’re safe here.",
              ),
              const SizedBox(height: 16),

              Text("Quick actions", style: titleStyle),
              const SizedBox(height: 12),

              ActionCard(
                title: "Patient Submissions",
                subtitle: "Review assessments and follow up safely",
                icon: Icons.inbox_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TherapistInboxScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              ActionCard(
                title: "Mood Check-in",
                subtitle: "Quick daily reflection",
                icon: Icons.mood_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mood Check-in"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              ActionCard(
                title: "Breathing Exercise",
                subtitle: "60 seconds calm breathing",
                icon: Icons.spa_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Breathing"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),

              ActionCard(
                title: "Booking Requests",
                subtitle: "Accept or reject patient sessions",
                icon: Icons.event_note_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TherapistRequestsScreen(
                        therapistId: "t1", // ✅ must match therapist profile id
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              Text("Recent activity", style: titleStyle),
              const SizedBox(height: 12),

              const InfoTile(
                title: "No activity yet",
                subtitle: "Once you review a submission, you’ll see it here.",
                icon: Icons.history_rounded,
              ),
              const SizedBox(height: 10),
              const InfoTile(
                title: "Tip for today",
                subtitle: "Keep sessions brief and supportive. Use gentle questions.",
                icon: Icons.lightbulb_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
