import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tameenidz/features/shared/domain/models/agent_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class CommissionWalletCard extends StatelessWidget {
  final AgentModel agent;

  const CommissionWalletCard({super.key, required this.agent});

  String _formatDZD(double val) {
    return '${NumberFormat('#,###', 'ar').format(val.round())} دج';
  }

  @override
  Widget build(BuildContext context) {
    const Color accentGold = Color(0xFFC9A84C);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A2A), Color(0xFF2E5E3E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A2A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: accentGold, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.myWallet,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatDZD(agent.walletBalance),
            style: const TextStyle(
              color: accentGold,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          Text(
            l10n.accumulatedCommissions,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showWithdrawalSheet(context, l10n),
            icon: const Icon(Icons.arrow_downward, color: accentGold, size: 18),
            label: Text(
              l10n.requestWithdrawal,
              style: const TextStyle(
                color: accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: accentGold),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalSheet(BuildContext context, AppLocalizations l10n) {
    final amountCtrl = TextEditingController();
    final ccpCtrl = TextEditingController();
    const Color accentGold = Color(0xFFC9A84C);
    const Color darkGreen = Color(0xFF1A3A2A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFFDF8F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.account_balance_outlined, color: darkGreen, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    l10n.requestWithdrawal,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.availableBalance}: ${_formatDZD(agent.walletBalance)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Amount field
              Text(l10n.withdrawalAmount, style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.monetization_on_rounded, color: accentGold),
                  suffixText: 'DZD',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGold, width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // CCP field
              Text(l10n.ccpAccountNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: ccpCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'XXXXXXXXXX XX',
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: accentGold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGold, width: 1.5)),
                ),
              ),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.pleaseEnterValidQuote)),
                      );
                      return;
                    }
                    if (amount > agent.walletBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.insufficientBalance)),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.withdrawalRequestSent),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(l10n.requestWithdrawal, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: accentGold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
