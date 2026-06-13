import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/utils/number_utils.dart';

class TransactionTile extends StatelessWidget {
  final String clientName;
  final String operatorCode;
  final String planType;
  final double premium;
  final double profit;
  final DateTime date;
  final bool isPending;

  const TransactionTile({
    super.key,
    required this.clientName,
    required this.operatorCode,
    required this.planType,
    required this.premium,
    required this.profit,
    required this.date,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final nf = safeNumberFormat(context);

    String dateStr;
    try {
      dateStr = DateFormat('dd MMM yyyy', locale).format(date);
    } catch (_) {
      try {
        final lang = Localizations.localeOf(context).languageCode;
        dateStr = DateFormat('dd MMM yyyy', lang).format(date);
      } catch (_) {
        dateStr = DateFormat('dd MMM yyyy', 'fr').format(date);
      }
    }

    final operatorDisplay =
        operatorCode.toUpperCase() == 'ITTIHAD'
            ? AppLocalizations.of(context)!.algeriaUnited
            : AppLocalizations.of(context)!.operatorTakaful;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isPending ? Colors.amber : AppColors.takafulGreen).withValues(
            alpha: 0.15,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isPending ? Colors.amber : AppColors.takafulGreen)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isPending ? '⏳' : '✅',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.colors.darkText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '$operatorDisplay · $planType',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.slate500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Profit amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${nf.format(profit.toInt())}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.takafulGreen,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.dzd,
                style: TextStyle(fontSize: 11, color: context.colors.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
