import 'package:flutter/material.dart';
import '../../../core/assessment/assessment_store.dart';
import '../../../core/theme/app_colors.dart';
import 'therapist_submission_details_screen.dart';

class TherapistInboxScreen extends StatelessWidget {
  const TherapistInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AssessmentStore.instance.submissions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Submissions"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Text(
                  "No submissions yet.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(22),
                itemBuilder: (_, i) {
                  final p = items[i];
                  final flags = [
                    if (p.flaggedSafety) "SAFETY",
                    if (!p.flaggedSafety && p.flaggedForFollowUp) "FOLLOW-UP",
                  ];

                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TherapistSubmissionDetailsScreen(
                            packet: p,
                            indexLabel: "#${items.length - i}",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Submission #${items.length - i}",
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Submitted: ${p.submittedAt}",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (flags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: flags
                                  .map(
                                    (t) => Chip(
                                      label: Text(t),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            "Answers captured: ${p.answers.length}",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: items.length,
              ),
      ),
    );
  }
}
