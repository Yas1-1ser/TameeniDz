import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'payment_receipt.dart';

class PaymentReceiptView extends StatelessWidget {
  final ScreenshotController screenshotController;
  final String receiptNumber;
  final String dateStr;
  final String methodName;
  final String amountText;
  final AppLocalizations l10n;
  final VoidCallback onBackToDashboard;
  final VoidCallback onShareReceipt;

  const PaymentReceiptView({
    super.key,
    required this.screenshotController,
    required this.receiptNumber,
    required this.dateStr,
    required this.methodName,
    required this.amountText,
    required this.l10n,
    required this.onBackToDashboard,
    required this.onShareReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accepted.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.accepted,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.paymentReceiptTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.send_rounded, size: 14, color: AppColors.accepted),
              const SizedBox(width: 6),
              Text(
                l10n.paymentReceiptSentToOperator,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accepted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Screenshot(
            controller: screenshotController,
            child: PaymentReceipt(
              receiptNumber: receiptNumber,
              dateStr: dateStr,
              methodName: methodName,
              amountText: amountText,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0097A7).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0097A7).withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF0097A7), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.paymentVerified,
                    style: const TextStyle(
                      color: Color(0xFF0097A7),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBackToDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.backToDashboard, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShareReceipt,
              icon: const Icon(Icons.share_rounded, size: 20),
              label: Text(l10n.downloadReceipt, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
