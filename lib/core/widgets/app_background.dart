import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean, unified background used across screens.
/// Uses AppColors only to avoid any Material3 color-scheme surprises.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background + subtle top tint
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryTeal.withOpacity(0.05),
                  AppColors.scaffoldBackground,
                  AppColors.primaryTeal.withOpacity(0.01),
                  AppColors.scaffoldBackground,
                ],
                // ✅ FIX: stops length must match colors length (4)
                stops: const [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),
        ),

        // Soft bottom wash for depth
        Positioned(
          left: 0,
          right: 0,
          bottom: -120,
          child: IgnorePointer(
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  center: const Alignment(0.0, 0.0),
                  colors: [
                    AppColors.tertiarySea.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
