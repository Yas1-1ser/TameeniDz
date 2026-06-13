import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class PaymentReceipt extends StatelessWidget {
  final String receiptNumber;
  final String dateStr;
  final String methodName;
  final String amountText;

  const PaymentReceipt({
    super.key,
    required this.receiptNumber,
    required this.dateStr,
    required this.methodName,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.slate200),
      ),
      child: Column(
        children: [
          _buildReceiptRow(
            context,
            'Receipt Number',
            receiptNumber,
            Icons.tag_rounded,
          ),
          const Divider(height: 20),
          _buildReceiptRow(
            context,
            'Payment Date',
            dateStr,
            Icons.calendar_today_rounded,
          ),
          const Divider(height: 20),
          _buildReceiptRow(
            context,
            'Payment Method',
            methodName,
            Icons.credit_card_rounded,
          ),
          Divider(height: 20),
          _buildReceiptRow(
            context,
            'Amount Paid',
            amountText,
            Icons.account_balance_wallet_rounded,
            valueColor: AppColors.primaryGreen,
            valueBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.slate500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? colors.darkText,
                  fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
