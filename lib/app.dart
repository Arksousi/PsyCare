import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/app_settings_store.dart';
import 'presentation/screens/welcome/welcome_screen.dart';

class PsyCareApp extends StatelessWidget {
  const PsyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsStore.instance;

    return ValueListenableBuilder<Color>(
      valueListenable: settings.seedColor,
      builder: (context, seed, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: settings.themeMode,
          builder: (context, mode, __) {
            return MaterialApp(
              title: 'PsyCare',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.lightTheme,
              themeMode: mode,
              home: const WelcomeScreen(),
            );
          },
        );
      },
    );
  }
}
