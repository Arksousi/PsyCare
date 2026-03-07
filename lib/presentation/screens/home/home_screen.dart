import 'package:flutter/material.dart';

import '../../../core/models/user_role.dart';
import 'anonymous_home_screen.dart';
import 'patient_home_screen.dart';
import 'therapist_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.isAnonymous,
    this.role,
    this.displayName,
    this.asTab = false,
  });

  final bool isAnonymous;
  final UserRole? role;
  final String? displayName;
  final bool asTab;

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (isAnonymous) {
      content = const AnonymousHomeScreen();
    } else if (role == UserRole.therapist) {
      content = TherapistHomeScreen(displayName: displayName ?? "Therapist");
    } else {
      content = PatientHomeScreen(displayName: displayName ?? "Patient");
    }

    // ✅ Avoid nested Scaffolds (patient/therapist screens already have Scaffold)
    if (asTab) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text("PsyCare"),
      ),
      body: content,
    );
  }
}
