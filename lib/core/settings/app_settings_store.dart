import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Lightweight in-memory settings store.
///
/// Keeps the same concept used elsewhere in the project (simple singleton state).
/// If you want persistence later, we can back this with SharedPreferences.
class AppSettingsStore {
  AppSettingsStore._();
  static final AppSettingsStore instance = AppSettingsStore._();

  /// Controls light/dark/system mode.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  /// Seed color used to build the Material 3 color scheme.
  final ValueNotifier<Color> seedColor = ValueNotifier<Color>(
    AppColors.primaryTeal,
  );

  void setThemeMode(ThemeMode mode) => themeMode.value = mode;
  void setSeedColor(Color color) => seedColor.value = color;

  void dispose() {
    themeMode.dispose();
    seedColor.dispose();
  }
}
