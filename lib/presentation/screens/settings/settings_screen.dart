import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local settings (demo only)
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _sounds = true;
  bool _vibration = true;
  bool _biometricLock = false;

  String _language = 'English';
  String _privacyMode = 'Standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _sectionTitle('Appearance'),
          _card(
            children: [
              _switchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                subtitle: 'Reduce brightness and eye strain',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _divider(),
              _navTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _language,
                onTap: () => _pickLanguage(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionTitle('Notifications'),
          _card(
            children: [
              _switchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push notifications',
                subtitle: 'Reminders, updates, and messages',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              _divider(),
              _switchTile(
                icon: Icons.volume_up_outlined,
                title: 'Sounds',
                subtitle: 'Notification sounds',
                value: _sounds,
                onChanged: (v) => setState(() => _sounds = v),
              ),
              _divider(),
              _switchTile(
                icon: Icons.vibration_outlined,
                title: 'Vibration',
                subtitle: 'Haptic feedback for alerts',
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionTitle('Privacy & Security'),
          _card(
            children: [
              _navTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy mode',
                subtitle: _privacyMode,
                onTap: () => _pickPrivacyMode(context),
              ),
              _divider(),
              _switchTile(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric lock',
                subtitle: 'Require fingerprint/face to open app',
                value: _biometricLock,
                onChanged: (v) => setState(() => _biometricLock = v),
              ),
              _divider(),
              _navTile(
                icon: Icons.delete_outline,
                title: 'Clear local data',
                subtitle: 'Reset app preferences on this device',
                danger: true,
                onTap: _confirmClearLocalData,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionTitle('Support'),
          _card(
            children: [
              _navTile(
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                subtitle: 'Common questions and guidance',
                onTap: () => _snack('Help & FAQ is not connected yet.'),
              ),
              _divider(),
              _navTile(
                icon: Icons.info_outline,
                title: 'About PsyCare',
                subtitle: 'Version, policy, and app info',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 0,
            offset: Offset(0, 10),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.border);

  // ✅ FIXED: no placeholders, real title/subtitle
  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryTeal,
      secondary: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryTeal),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    const dangerColor = Color(0xFFB42318);
    const dangerBg = Color(0xFFFEE4E2);

    final titleColor = danger ? dangerColor : AppColors.textPrimary;
    final iconColor = danger ? dangerColor : AppColors.primaryTeal;
    final bgColor =
    danger ? dangerBg : AppColors.primaryTeal.withOpacity(0.12);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
    );
  }

  // ---------- Actions ----------

  Future<void> _pickLanguage(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _bottomSheetPicker(
        context: context,
        title: 'Language',
        items: const ['English', 'Arabic', 'Spanish', 'Greek'],
        selected: _language,
      ),
    );

    if (result != null) setState(() => _language = result);
  }

  Future<void> _pickPrivacyMode(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _bottomSheetPicker(
        context: context,
        title: 'Privacy mode',
        items: const [
          'Standard',
          'Private (hide previews)',
          'Strict (lock sensitive screens)',
        ],
        selected: _privacyMode,
      ),
    );

    if (result != null) setState(() => _privacyMode = result);
  }

  Widget _bottomSheetPicker({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selected,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((e) {
              final isSelected = e == selected;
              return ListTile(
                onTap: () => Navigator.pop(context, e),
                title: Text(
                  e,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? AppColors.primaryTeal
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primaryTeal)
                    : const Icon(Icons.circle_outlined,
                    color: AppColors.textSecondary),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmClearLocalData() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Clear local data?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will reset settings on this device. It will not delete your account.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _darkMode = false;
                _pushNotifications = true;
                _sounds = true;
                _vibration = true;
                _biometricLock = false;
                _language = 'English';
                _privacyMode = 'Standard';
              });
              Navigator.pop(context);
              _snack('Local settings cleared.');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'About PsyCare',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'PsyCare is a mental wellness app prototype.\n\nIncludes assessment flow, therapist review, and chat.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
