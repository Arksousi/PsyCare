import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class AssessmentSubmittedScreen extends StatelessWidget {
  const AssessmentSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitted"),
        automaticallyImplyLeading: false, // Prevent going back to assessment
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thank you card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Thank you.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your responses have been sent to your therapist for review.\n\n"
                          "A therapist will contact you to support you safely.",
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Safety notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Text(
                  "If you feel unsafe right now, please contact local emergency services immediately.",
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),

              const Spacer(),

              // Back to Home
              AppButton(
                label: "Back to Home",
                icon: Icons.home_rounded,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
