import 'package:flutter/material.dart';
import 'slots_page.dart';

class TherapistDetailPage extends StatelessWidget {
  const TherapistDetailPage({
    super.key,
    required this.therapistId,
    required this.therapistData,
  });

  final String therapistId;
  final Map<String, dynamic> therapistData;

  @override
  Widget build(BuildContext context) {
    final name = therapistData['fullName'] ?? '';
    final location = therapistData['locationText'] ?? '';
    final ratingAvg = therapistData['ratingAvg'] ?? 0;
    final ratingCount = therapistData['ratingCount'] ?? 0;
    final therapiesCount = therapistData['therapiesCount'] ?? 0;
    final bio = therapistData['bio'] ?? '';
    final specialties = (therapistData['specialties'] as List?)?.join(', ') ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Rating: $ratingAvg ★  ($ratingCount reviews)'),
            const SizedBox(height: 8),
            Text('Therapies count: $therapiesCount'),
            const SizedBox(height: 12),
            Text('Specialties: $specialties'),
            const SizedBox(height: 12),
            Text(bio),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('View Available Slots'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SlotsPage(therapistId: therapistId),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
