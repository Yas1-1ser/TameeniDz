import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String price;
  final IconData icon;
  final Color themeColor;
  final bool isDark;
  final String? badge;
  final List<String>? details;
  final String? operatorCode;
  final Color? operatorColor;

  const PlanCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.price,
    required this.icon,
    required this.themeColor,
    this.isDark = false,
    this.badge,
    this.details,
    this.operatorCode,
    this.operatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;
    
    final operatorName = operatorCode?.toUpperCase() == 'ITTIHAD'
        ? l10n.algeriaUnited
        : operatorCode?.toUpperCase() == 'TAKAFUL'
            ? l10n.operatorTakaful
            : null;

    // Adjust card color based on explicit isDark parameter OR system theme
    final cardBg = (isDark || isThemeDark) ? colors.surfaceContainer : Colors.white;
    final textColor = (isDark || isThemeDark) ? Colors.white : colors.darkText;
    final subtextColor = (isDark || isThemeDark) ? Colors.white60 : colors.onSurfaceVariant;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark || isThemeDark) ? Colors.white10 : themeColor.withOpacity(0.08),
        ),
        boxShadow: (isDark || isThemeDark) ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (operatorName != null && operatorColor != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: operatorColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        operatorName,
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                    ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor, fontFamily: 'Cairo')),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Icon(icon, color: themeColor, size: 28),
              const SizedBox(height: 12),
              Text(title.isNotEmpty ? title : l10n.takafulPackage, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(fontSize: 11, color: subtextColor, fontFamily: 'Cairo')),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: (isDark || isThemeDark) ? colors.inversePrimary : themeColor, fontFamily: 'Cairo')),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: textColor.withOpacity(0.1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
