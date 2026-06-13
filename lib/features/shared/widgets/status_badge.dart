import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../enums/policy_status.dart';

class StatusBadge extends StatelessWidget {
  final PolicyStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case PolicyStatus.pending:
        bg = AppColors.statusAmberBg;
        fg = AppColors.statusAmberFg;
        label = AppLocalizations.of(context)!.statusPending;
        break;
      case PolicyStatus.accepted:
        bg = AppColors.statusGreenBg;
        fg = AppColors.statusGreenFg;
        label = AppLocalizations.of(context)!.statusAccepted;
        break;
      case PolicyStatus.paid:
        bg = AppColors.statusGreenBg;
        fg = AppColors.statusGreenFg;
        label = AppLocalizations.of(context)!.statusPaid;
        break;
      case PolicyStatus.rejected:
        bg = AppColors.statusRedBg;
        fg = AppColors.statusRedFg;
        label = AppLocalizations.of(context)!.statusRejected;
        break;
      case PolicyStatus.modificationRequested:
        bg = AppColors.goldLight;
        fg = AppColors.goldDeep;
        label = AppLocalizations.of(context)!.statusModReq;
        break;
      case PolicyStatus.insurancePending:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        label = AppLocalizations.of(context)!.insuranceRequest;
        break;
      case PolicyStatus.issued:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'بوليصة مُصدرة'; // 'Policy Issued'
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSansArabic(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

