import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import '../patient/patient_home.dart';
import '../therapist/therapist_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }

        final user = authSnap.data;
        if (user == null) {
          return const LoginPage();
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _Loading();
            }

            if (userSnap.hasError) {
              return _ErrorView('Error loading profile: ${userSnap.error}');
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return _CreateProfileFallback(uid: user.uid);
            }

            final data = userSnap.data!.data()!;
            final role = (data['role'] as String?)?.trim();

            if (role == 'patient') return const PatientHomePage();
            if (role == 'therapist') return const TherapistHomePage();

            return _ErrorView('Invalid role: "$role"');
          },
        );
      },
    );
  }
}
class _CreateProfileFallback extends StatefulWidget {
  const _CreateProfileFallback({required this.uid});
  final String uid;

  @override
  State<_CreateProfileFallback> createState() => _CreateProfileFallbackState();
}

class _CreateProfileFallbackState extends State<_CreateProfileFallback> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _create();
  }

  Future<void> _create() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'patient', // default if missing (can be changed later)
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorView('Could not create profile automatically:\n$_error');
    }
    return const _Loading();
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
