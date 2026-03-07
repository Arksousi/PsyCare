import 'package:flutter/material.dart';

import '../../../core/models/user_role.dart';
import '../../../core/navigation/app_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_button.dart';
import '../auth/login_screen.dart';
import '../main/main_nav_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textMuted = AppColors.textSecondary;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const _Header(),
                const SizedBox(height: 26),
                const Expanded(child: _CalmHeroCard()),
                const SizedBox(height: 18),

                AppButton(
                  label: "Continue as Anonymous",
                  isSecondary: true,
                  icon: Icons.visibility_off_rounded,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      AppTransitions.fadeSlide(
                        const MainNavScreen(
                          isAnonymous: true,
                          role: UserRole.patient,
                        ),
                      ),
                    );
                  },
                ),

                AppButton(
                  label: "Get Started",
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(AppTransitions.fadeSlide(const LoginScreen()));
                  },
                ),

                const SizedBox(height: 10),
                Text(
                  "By continuing, you agree to a calm and safe experience.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   Header with PsyCare Logo
   =========================== */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "PsyCare",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 4),
            Text(
              "A calm space for support",
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

/* ===========================
   Hero Card
   =========================== */

class _CalmHeroCard extends StatefulWidget {
  const _CalmHeroCard();

  @override
  State<_CalmHeroCard> createState() => _CalmHeroCardState();
}

class _CalmHeroCardState extends State<_CalmHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.98, end: 1).animate(curved);

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SoftBadge(),
              const SizedBox(height: 16),

              const Text(
                "Feel heard.\nFeel safe.",
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Choose the right path for you — therapist or patient — and start with a simple, calm experience.",
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Private • Supportive • Simple",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===========================
   Soft Badge
   =========================== */

class _SoftBadge extends StatelessWidget {
  const _SoftBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.spa_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            "Trusted care, calm design",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
