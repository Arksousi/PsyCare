import 'package:flutter/material.dart';

import '../../../core/assessment/assessment_flow_screen.dart';
import '../../../core/booking/booking_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../booking/therapist_list_screen.dart';
import 'home_widgets.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key, required this.displayName});

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
                subtitle: "Role: Patient • You’re safe here.",
              ),
              const SizedBox(height: 16),

              Text("Quick actions", style: titleStyle),
              const SizedBox(height: 12),

              ActionCard(
                title: "Start Assessment",
                subtitle: "Short, adaptive questions",
                icon: Icons.assignment_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AssessmentFlowScreen(),
                    ),
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
                title: "Book Your Session",
                subtitle: "Choose a therapist and schedule a session",
                icon: Icons.calendar_month_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TherapistListScreen(
                        patientId: "patient_1", // ✅ replace later with Firebase uid
                        patientName: displayName,
                        type: SessionType.video, // ✅ default
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
                subtitle: "Once you complete an assessment, you’ll see it here.",
                icon: Icons.history_rounded,
              ),
              const SizedBox(height: 10),
              const InfoTile(
                title: "Tip for today",
                subtitle: "Take 3 slow breaths before you start your day.",
                icon: Icons.lightbulb_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
