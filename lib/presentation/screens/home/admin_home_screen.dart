import 'package:flutter/material.dart';

import '../../../core/assessment/assessment_store.dart';
import '../../../core/assessment/assessment_models.dart';
import '../../../core/widgets/app_background.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key, required this.displayName});
  final String displayName;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _filterIndex = 0; // 0=All, 1=Follow-up, 2=Safety

  @override
  Widget build(BuildContext context) {
    final store = AssessmentStore.instance;
    final submissions = store.submissions;

    final total = submissions.length;
    final followUpCount = submissions.where((s) => s.flaggedForFollowUp).length;
    final safetyCount = submissions.where((s) => s.flaggedSafety).length;

    final filtered = submissions.where((s) {
      if (_filterIndex == 1) return s.flaggedForFollowUp;
      if (_filterIndex == 2) return s.flaggedSafety;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              _header(context, name: widget.displayName),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      title: "Total",
                      value: "$total",
                      icon: Icons.analytics_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      context,
                      title: "Follow-up",
                      value: "$followUpCount",
                      icon: Icons.flag_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      context,
                      title: "Safety",
                      value: "$safetyCount",
                      icon: Icons.warning_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _filterChips(context),

              const SizedBox(height: 10),

              _sectionTitle("Recent submissions"),
              const SizedBox(height: 10),

              if (filtered.isEmpty)
                _emptyCard(context)
              else
                ...filtered
                    .take(20)
                    .map((p) => _submissionTile(context, p))
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, {required String name}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.admin_panel_settings_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $name 👋",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage submissions and triage flags (demo).",
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(String label, int idx) {
      final selected = _filterIndex == idx;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filterIndex = idx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [chip("All", 0), chip("Follow-up", 1), chip("Safety", 2)],
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
    );
  }

  Widget _emptyCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        "No submissions found for this filter.",
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _submissionTile(BuildContext context, AssessmentPacket p) {
    final cs = Theme.of(context).colorScheme;

    final flags = <String>[];
    if (p.flaggedForFollowUp) flags.add("Follow-up");
    if (p.flaggedSafety) flags.add("Safety");

    final subtitle = flags.isEmpty ? "No flags" : flags.join(" • ");

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer.withOpacity(0.55),
          child: Icon(Icons.assignment_rounded, color: cs.primary),
        ),
        title: Text(
          _formatDate(p.submittedAt),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        onTap: () {
          // For now: simple details dialog (no extra screens yet)
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Submission details"),
              content: Text(
                "Submitted: ${p.submittedAt}\n"
                "Answers: ${p.answers.length}\n"
                "Flagged Follow-up: ${p.flaggedForFollowUp}\n"
                "Flagged Safety: ${p.flaggedSafety}",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$y-$m-$d  $hh:$mm";
  }
}
