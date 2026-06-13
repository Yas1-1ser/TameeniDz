import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

/// Reusable app logo widget.
/// Shows the real logo image if available, falls back to the shield icon.
/// 
/// Usage:
///   AppLogo(size: 80)          // default
///   AppLogo(size: 64, withGlow: false)
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
    this.withRing = true,
    this.withGlow = true,
  });

  final double size;
  final bool withRing;
  final bool withGlow;

  @override
  Widget build(BuildContext context) {
    final innerSize = size;
    final ringSize = size * 1.45;
    final glowSize = size * 1.75;

    final logoWidget = Container(
      width: innerSize,
      height: innerSize,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(innerSize * 0.27),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.28),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      // Try to load the real logo image — fall back to icon if missing
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerSize * 0.27),
        child: Image.asset(
          'assets/images/logotameen.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.shield_rounded,
            color: AppColors.goldAccent,
            size: innerSize * 0.5,
          ),
        ),
      ),
    );

    if (!withRing) return logoWidget;

    return SizedBox(
      width: glowSize,
      height: glowSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft glow circle
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
            ),
          ),
          // Middle ring
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.offWhiteContainer,
              border: Border.all(
                color: context.colors.outlineVariant,
                width: 1,
              ),
            ),
          ),
          // Logo
          logoWidget,
        ],
      ),
    );
  }
}
