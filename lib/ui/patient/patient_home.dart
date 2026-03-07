import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'therapist_list_page.dart';


class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TherapistListPage()),
            );
          },
          child: const Text('Book Your Session'),
        ),
      ),
    );
  }
}
