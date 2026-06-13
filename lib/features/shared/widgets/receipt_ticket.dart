import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';

class ReceiptTicket extends StatelessWidget {
  final PolicyModel policy;

  const ReceiptTicket({super.key, required this.policy});

  String tr(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'paymentReceiptTitle':
        return l10n.paymentReceiptTitle;
      case 'fullName':
        return l10n.fullName;
      case 'policyType':
        return l10n.policyType;
      case 'paymentDate':
        return l10n.paymentDate;
      case 'totalAmount':
        return l10n.totalAmount;
      case 'dzd':
        return l10n.dzd;
      case 'sovereignTrustVerified':
        return l10n.sovereignTrustVerified;
      default:
        return key;
    }
  }

  Widget _receiptRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // L10n migrated to tr()
    final paidDate =
        policy.paidAt != null
            ? DateFormat('dd MMM yyyy – HH:mm').format(policy.paidAt!)
            : '---';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0097A7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(context, 'paymentReceiptTitle').toUpperCase(),
                        style: TextStyle(
                          color: context.colors.surface,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        policy.receiptNumber ?? 'N/A',
                        style: TextStyle(
                          color: context.colors.surface.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Middle Content (Ticket Style)
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _receiptRow(
                        context,
                        tr(context, 'fullName'),
                        policy.applicantName,
                      ),
                      const SizedBox(height: 12),
                      _receiptRow(
                        context,
                        tr(context, 'policyType'),
                        policy.type,
                      ),
                      const SizedBox(height: 12),
                      _receiptRow(
                        context,
                        tr(context, 'paymentDate'),
                        paidDate,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: DottedDivider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr(context, 'totalAmount'),
                            style: TextStyle(
                              color: context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${policy.amount.toStringAsFixed(0)} ${tr(context, 'dzd')}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0097A7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Punched ticket holes
                Positioned(
                  left: -10,
                  top: 90,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: context.colors.beigeBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  top: 90,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: context.colors.beigeBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFF0097A7).withValues(alpha: 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF0097A7),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr(context, 'sovereignTrustVerified').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0097A7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: context.colors.outlineVariant),
              ),
            );
          }),
        );
      },
    );
  }
}
