import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assessment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Text(
          "Next: Build the 10-question assessment UI",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
