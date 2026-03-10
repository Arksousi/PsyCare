import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/welcome/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PsyCareApp());
}

class PsyCareApp extends StatelessWidget {
  const PsyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PsyCare',

      theme: AppTheme.lightTheme,

      home: const WelcomeScreen(),
    );
  }
}
