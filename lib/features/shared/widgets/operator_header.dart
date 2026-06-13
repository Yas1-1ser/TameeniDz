import 'package:flutter/material.dart';

import 'package:tameenidz/core/theme/app_colors_extension.dart';

class OperatorHeader extends StatelessWidget {
  final String name;
  final String tagline;
  final Color themeColor;
  final String badgeText;
  final bool isIslamic;
  final String? logoPath;

  const OperatorHeader({
    super.key,
    required this.name,
    required this.tagline,
    required this.themeColor,
    required this.badgeText,
    this.isIslamic = false,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: isIslamic ? const Color(0xFFF8F5F0) : const Color(0xFF0F1923),
      ),
      child: Column(
        children: [
          // Logo Placeholder or Image
          Container(
            height: 90,
            width: 90,
            padding: EdgeInsets.all(logoPath != null ? 0 : 0),
            decoration: BoxDecoration(
              color: context.colors.offWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: logoPath != null 
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                          logoPath!,
                          fit: BoxFit.contain,
                        ),
                  )
                  : Icon(
                      isIslamic ? Icons.account_balance_rounded : Icons.hub_rounded,
                      size: 40,
                      color: themeColor,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isIslamic ? themeColor : context.colors.offWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tagline,
            style: TextStyle(
              fontSize: 14,
              color: isIslamic ? Colors.black54 : context.colors.offWhite.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isIslamic
                      ? themeColor.withValues(alpha: 0.1)
                      : const Color(0xFF2ECC71).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color:
                    isIslamic
                        ? themeColor.withValues(alpha: 0.3)
                        : const Color(0xFF2ECC71).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIslamic
                      ? Icons.verified_user_rounded
                      : Icons.verified_rounded,
                  size: 16,
                  color: isIslamic ? themeColor : const Color(0xFF2ECC71),
                ),
                const SizedBox(width: 8),
                Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isIslamic ? themeColor : const Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
