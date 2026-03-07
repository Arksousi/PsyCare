import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.height = 52,
    this.radius = 16,
  });

  final String label;
  final VoidCallback? onPressed; // ✅ allow disabled state
  final bool isSecondary;
  final IconData? icon;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Color bg = isSecondary ? AppColors.surface : AppColors.primaryTeal;
    final Color fg = isSecondary ? AppColors.primaryTeal : Colors.white;

    final ButtonStyle style = ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: Size.fromHeight(height),
      backgroundColor: bg,
      foregroundColor: fg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: isSecondary
            ? const BorderSide(color: AppColors.primaryTeal, width: 1.2)
            : BorderSide.none,
      ),
      disabledBackgroundColor:
      isSecondary ? AppColors.surface : AppColors.primaryTeal.withOpacity(0.45),
      disabledForegroundColor: isSecondary
          ? AppColors.primaryTeal.withOpacity(0.45)
          : Colors.white.withOpacity(0.75),
    );

    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
