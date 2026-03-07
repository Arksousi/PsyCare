import 'package:flutter/material.dart';

import '../home/admin_home_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';

class AdminNavScreen extends StatefulWidget {
  const AdminNavScreen({super.key, this.displayName = "Admin"});
  final String displayName;

  @override
  State<AdminNavScreen> createState() => _AdminNavScreenState();
}

class _AdminNavScreenState extends State<AdminNavScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      AdminHomeScreen(displayName: widget.displayName),
      const SettingsScreen(),
      const _AdminPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}

class _AdminPage extends StatelessWidget {
  const _AdminPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.verified_user_rounded),
            title: Text("Admin access"),
            subtitle: Text("Full access enabled (demo)."),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text("Log out"),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
