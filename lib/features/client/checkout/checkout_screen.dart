import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // Read policy data passed via extra
    final extra = GoRouterState.of(context).extra;
    String planName = l10n.unspecified;
    String duration = l10n.oneYear;
    double amount = 0;
    String? policyId;

    if (extra is Map<String, dynamic>) {
      planName = extra['planName'] as String? ?? l10n.unspecified;
      duration = extra['duration'] as String? ?? l10n.oneYear;
      amount = (extra['amount'] as num?)?.toDouble() ?? 0;
      policyId = extra['policyId'] as String?;
    }

    final formattedAmount = '${NumberFormat('#,###', 'ar').format(amount.round())} ${l10n.dzd}';

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: colors.beigeBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.checkout,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: PageEntryAnimation(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(context, colors, l10n, planName, duration, formattedAmount),
            const SizedBox(height: 24),
            _buildPaymentMethods(context, colors, l10n),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: SpringButton(child: ElevatedButton(
                onPressed: () {
                  if (policyId != null) {
                    context.push(AppRoutes.clientPayment(policyId), extra: {
                      'operatorId': extra is Map ? extra['operatorId'] : null,
                      'planId': extra is Map ? extra['planId'] : null,
                      'price': amount,
                    });
                  } else {
                    context.go(AppRoutes.paymentSuccess);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: colors.beigeCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  l10n.completePayment,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildOrderSummary(BuildContext context, AppColorsExtension colors, AppLocalizations l10n, String planName, String duration, String formattedAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _row(context, l10n.policyType, planName),
          _row(context, l10n.duration, duration),
          const Divider(height: 32),
          _row(context, l10n.totalAmount, formattedAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? null : context.colors.slate500, fontWeight: isTotal ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : null, color: isTotal ? AppColors.primaryGreen : null)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, AppColorsExtension colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _methodItem(context, colors, Icons.credit_card_rounded, l10n.dahabiaCard, true),
        _methodItem(context, colors, Icons.account_balance_rounded, l10n.bankTransfer, false),
      ],
    );
  }

  Widget _methodItem(BuildContext context, AppColorsExtension colors, IconData icon, String title, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryGreen.withValues(alpha: 0.05) : colors.beigeCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.primaryGreen : context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? AppColors.primaryGreen : context.colors.slate500),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontWeight: selected ? FontWeight.bold : null)),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
        ],
      ),
    );
  }
}
