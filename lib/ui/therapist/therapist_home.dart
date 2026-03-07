import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_slot_page.dart';
import 'my_slots_page.dart';
import 'booking_requests_page.dart';


class TherapistHomePage extends StatelessWidget {
  const TherapistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Create Availability Slot'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateSlotPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingRequestsPage()),
                  );
                },
                child: const Text('Booking Requesflutts'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
