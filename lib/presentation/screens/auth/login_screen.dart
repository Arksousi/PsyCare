import 'package:flutter/material.dart';

import '../../../core/models/user_role.dart';
import '../../../core/navigation/app_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import 'login_form_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _goToForm(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      AppTransitions.fadeSlide(LoginFormScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textMuted = AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose your role to continue in a calm and safe space.",
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 22),

              _RoleCard(
                title: "Login as Therapist",
                subtitle: "Access your sessions and patient requests.",
                icon: Icons.medical_services_rounded,
                onTap: () => _goToForm(context, UserRole.therapist),
              ),
              const SizedBox(height: 14),
              _RoleCard(
                title: "Login as Patient",
                subtitle: "Continue your journey with support and privacy.",
                icon: Icons.person_rounded,
                onTap: () => _goToForm(context, UserRole.patient),
              ),

              const Spacer(),

              AppButton(
                label: "Create Account",
                isSecondary: true,
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    AppTransitions.fadeSlide(const SignUpScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              Text(
                "Your privacy matters. We keep the experience calm and minimal.",
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
