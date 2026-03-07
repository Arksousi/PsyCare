import 'package:flutter/material.dart';
import '../../../core/assessment/assessment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/assessment/assessment_bank.dart';

class TherapistSubmissionDetailsScreen extends StatelessWidget {
  const TherapistSubmissionDetailsScreen({
    super.key,
    required this.packet,
    required this.indexLabel,
  });

  final AssessmentPacket packet;
  final String indexLabel;

  @override
  Widget build(BuildContext context) {
    final qMap = {for (final q in AssessmentBank.build()) q.id: q};

    return Scaffold(
      appBar: AppBar(
        title: Text("Submission $indexLabel"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            _HeaderCard(packet: packet),
            const SizedBox(height: 14),

            const Text(
              "Answers",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            ...packet.answers.map((a) {
              final q = qMap[a.questionId];
              final choice = q?.choices
                  .where((c) => c.id == a.choiceId)
                  .toList();
              final choiceText = (choice != null && choice.isNotEmpty)
                  ? choice.first.text
                  : a.choiceId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AnswerCard(
                  questionTitle: q?.title ?? a.questionId,
                  questionSubtitle: q?.subtitle ?? "",
                  answer: choiceText,
                ),
              );
            }),

            const SizedBox(height: 6),
            AppButton(
              label: "Open Chat ",
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chat UI is next step.")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.packet});

  final AssessmentPacket packet;

  @override
  Widget build(BuildContext context) {
    final flags = <String>[
      if (packet.flaggedSafety) "SAFETY",
      if (!packet.flaggedSafety && packet.flaggedForFollowUp) "FOLLOW-UP",
      if (!packet.flaggedSafety && !packet.flaggedForFollowUp) "NORMAL",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            "Submitted: ${packet.submittedAt}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flags
                .map(
                  (t) => Chip(
                    label: Text(t),
                    side: const BorderSide(color: AppColors.border),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(
            "Answers captured: ${packet.answers.length}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.questionTitle,
    required this.questionSubtitle,
    required this.answer,
  });

  final String questionTitle;
  final String questionSubtitle;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            questionTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          if (questionSubtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              questionSubtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              answer,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
