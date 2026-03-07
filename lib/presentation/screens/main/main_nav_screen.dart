import 'package:flutter/material.dart';

import '../../../core/chat/store.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

// Tabs
import '../auth/login_screen.dart';
import '../chat/chat_list_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({
    super.key,
    required this.isAnonymous,
    this.role,
    this.displayName,
  });

  final bool isAnonymous;
  final UserRole? role;
  final String? displayName;

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final store = ChatStore.instance;

    final bool isTherapist = widget.role == UserRole.therapist;

    // Demo chat identities
    final currentUserId =
    isTherapist ? store.demoTherapistId : store.demoPatientId;
    final currentUserName = isTherapist
        ? "Therapist"
        : (widget.isAnonymous ? "Friend" : (widget.displayName ?? "You"));

    final otherUserId = isTherapist ? store.demoPatientId : store.demoTherapistId;
    final otherUserName = isTherapist ? "Patient" : "Therapist";

    final chatTab = widget.isAnonymous
        ? const _ChatLockedScreen()
        : ChatListScreen(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
    );

    final tabs = <Widget>[
      HomeScreen(
        isAnonymous: widget.isAnonymous,
        role: widget.role,
        displayName: widget.displayName,
        asTab: true,
      ),
      chatTab,
      ProfileScreen(
        isAnonymous: widget.isAnonymous,
        role: widget.role ?? UserRole.patient,
        displayName: widget.displayName,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: tabs,
      ),

      // ✅ Force teal navigation colors (no purple leakage)
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryTeal.withOpacity(0.16),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.primaryTeal : AppColors.textSecondary,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(
              size: 22,
              color: selected ? AppColors.primaryTeal : AppColors.textSecondary,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatLockedScreen extends StatelessWidget {
  const _ChatLockedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(height: 12),
              const Text(
                "Login required",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "To keep users safe and verified, chat is available only after logging in.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),

              AppButton(
                label: "Go to Login",
                icon: Icons.login_rounded,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
