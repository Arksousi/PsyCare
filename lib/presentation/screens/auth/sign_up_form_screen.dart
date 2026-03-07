import 'package:flutter/material.dart';

import '../../../core/models/user_role.dart' as ui;
import '../../../core/navigation/app_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_button.dart';

import 'package:psycare/service/auth_service.dart';
import 'package:psycare/presentation/screens/main/main_nav_screen.dart';
import '../../../models/enums.dart' as db;

class SignUpFormScreen extends StatefulWidget {
  const SignUpFormScreen({super.key, required this.role});
  final ui.UserRole role;

  @override
  State<SignUpFormScreen> createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) =>
      InputDecoration(labelText: label, prefixIcon: Icon(icon));

  Future<void> _createAccount() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final auth = AuthService();

    // Convert UI role -> DB role
    final db.UserRole dbRole = widget.role == ui.UserRole.therapist
        ? db.UserRole.therapist
        : db.UserRole.patient;

    try {
      await auth.signUpEmailPassword(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _name.text.trim(),
        role: dbRole,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        AppTransitions.fadeSlide(
          MainNavScreen(
            isAnonymous: false,
            role: widget.role,
            displayName: _name.text.trim(),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.role.label;

    return Scaffold(
      appBar: AppBar(
        title: Text("$roleLabel Sign Up"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Create your account",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign up as $roleLabel to start using PsyCare.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 26),

                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: _dec(
                        "Full Name",
                        Icons.person_outline_rounded,
                      ),
                      validator: (v) {
                        final value = (v ?? "").trim();
                        if (value.length < 2) return "Name too short.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: _dec("Email", Icons.email_outlined),
                      validator: (v) {
                        final value = (v ?? "").trim();
                        if (value.isEmpty) return "Email is required.";
                        if (!value.contains("@")) return "Invalid email.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _createAccount(),
                      decoration: _dec("Password", Icons.lock_outline_rounded),
                      validator: (v) {
                        if ((v ?? "").length < 6) return "Password too short.";
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    AppButton(
                      label: _loading ? "Creating..." : "Create Account",
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: _loading ? null : _createAccount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
