import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RenewalAlertBanner extends StatelessWidget {
  final int daysRemaining;
  const RenewalAlertBanner({super.key, required this.daysRemaining});

  (Color, String, IconData) get _config {
    if (daysRemaining <= 1) {
      return (
        AppColors.alert24h,
        'موعد التجديد خلال 24 ساعة',
        Icons.warning_amber,
      );
    }
    if (daysRemaining <= 7) {
      return (
        AppColors.alert7d,
        'موعد التجديد بعد $daysRemaining أيام',
        Icons.timer,
      );
    }
    return (
      AppColors.alert30d,
      'موعد التجديد بعد $daysRemaining يوماً',
      Icons.notifications_active,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (color, message, icon) = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
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
