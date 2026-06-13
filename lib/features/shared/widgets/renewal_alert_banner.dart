import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';

class RenewalAlertBanner extends StatelessWidget {
  final int daysRemaining;
  const RenewalAlertBanner({super.key, required this.daysRemaining});

  (Color, String, IconData) _config(BuildContext context) {
    if (daysRemaining <= 1) {
      return (
        AppColors.alert24h,
        AppLocalizations.of(context)!.renewalAlert24H,
        Icons.warning_amber,
      );
    }
    return (
      daysRemaining <= 7 ? AppColors.alert7d : AppColors.alert30d,
      '${AppLocalizations.of(context)!.renewalAlertDays} ${daysRemaining.toString()}',
      daysRemaining <= 7 ? Icons.timer : Icons.notifications_active,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (color, message, icon) = _config(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

