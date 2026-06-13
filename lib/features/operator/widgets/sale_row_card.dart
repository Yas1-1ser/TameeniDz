import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tameenidz/features/shared/domain/models/sale_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class SaleRowCard extends StatelessWidget {
  final SaleModel sale;

  const SaleRowCard({super.key, required this.sale});

  String _formatDZD(double val) {
    return '${NumberFormat('#,###', 'ar').format(val.round())} DZD';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    const Color accentGold = Color(0xFFC9A84C);
    const Color darkGreen = Color(0xFF1A3A2A);
    const Color cardWhite = Color(0xFFFFFFFF);
    const Color goldLight = Color(0xFFFDF3DC);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: goldLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPolicyIcon(sale.policyType),
              color: accentGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.clientName,
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${sale.policyType} • ${sale.companyName ?? AppLocalizations.of(context)!.companyUnspecified}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  _formatDate(sale.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDZD(sale.totalAmount),
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(context, sale.status),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPolicyIcon(String type) {
    switch (type.toLowerCase()) {
      case 'auto':
      case 'سيارات':
        return Icons.directions_car_outlined;
      case 'home':
      case 'سكن':
        return Icons.home_outlined;
      case 'health':
      case 'صحة':
        return Icons.medical_services_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String text;

    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = l10n.statusAccepted;
        break;
      case 'paid':
        color = Colors.blue;
        text = l10n.statusPaid;
        break;
      default:
        color = const Color(0xFFC9A84C);
        text = l10n.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

