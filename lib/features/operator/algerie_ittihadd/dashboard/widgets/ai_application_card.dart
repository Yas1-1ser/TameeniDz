// lib/features/operator/algerie_ittihadd/dashboard/widgets/ai_application_card.dart
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/features/shared/widgets/status_badge.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AiApplicationCard extends StatelessWidget {
  final PolicyModel policy;
  final VoidCallback onTap;

  const AiApplicationCard({
    super.key,
    required this.policy,
    required this.onTap,
  });

  Color _getStatusColor(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.pending:
        return kStatusPending;
      case PolicyStatus.accepted:
        return kStatusAccepted;
      case PolicyStatus.paid:
        return kStatusPaid;
      case PolicyStatus.rejected:
        return kStatusRejected;
      case PolicyStatus.modificationRequested:
        return kStatusMod;
      case PolicyStatus.insurancePending:
        return const Color(0xFF1565C0);
      case PolicyStatus.issued:
        return const Color(0xFF1B5E20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final statusColor = _getStatusColor(policy.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(kRadiusMd),
          boxShadow: [kCardShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 4px Status Border
              Container(width: 4, color: statusColor),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.applicantName,
                        style: GoogleFonts.amiri(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kInk,
                        ),
                      ),
                      if (policy.nin != null && policy.nin!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.ninLabel}: ${policy.nin}',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kGoldDeep,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        policy.planName ?? 'وثيقة',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: kInkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Status Badge and Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusBadge(status: policy.status),
                    const SizedBox(height: 8),
                    Icon(
                      isRtl
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: kInkFaint,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
