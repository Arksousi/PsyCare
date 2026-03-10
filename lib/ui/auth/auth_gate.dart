import 'package:flutter/material.dart';

import 'login_page.dart';
import '../patient/patient_home.dart';
import '../therapist/therapist_home.dart';
import '../../service/auth_service.dart';
import '../../models/app_user.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthService().authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting && !authSnap.hasData) {
          return const _Loading();
        }

        final user = authSnap.data;
        if (user == null && AuthService().currentUser == null) {
          return const LoginPage();
        }
        
        // We might be waiting on the stream but have a currentUser
        final activeUser = user ?? AuthService().currentUser;

        if (activeUser != null) {
          if (activeUser.role == 'patient') return const PatientHomePage();
          if (activeUser.role == 'therapist') return const TherapistHomePage();
          return _ErrorView('Invalid role: "${activeUser.role}"');
        }

        return const LoginPage();
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
