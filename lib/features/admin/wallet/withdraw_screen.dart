import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _ccpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _ccpController.dispose();
    super.dispose();
  }

  void _handleWithdraw(AppLocalizations l10n) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      final colors = context.colors;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.withdrawRequestUnderReview, style: const TextStyle(fontFamily: 'Cairo')), 
          backgroundColor: colors.primary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: buildAdminAppBar(
        context, 
        l10n.withdraw,
        actions: [
          IconButton(
            icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, color: colors.goldAccent),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageEntryAnimation(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredListItem(
                delay: const Duration(milliseconds: 0),
                child: _buildBalanceHeader(l10n),
              ),
              const SizedBox(height: 32),
              StaggeredListItem(
                delay: const Duration(milliseconds: 100),
                child: _buildWithdrawForm(l10n),
              ),
              const SizedBox(height: 40),
              StaggeredListItem(
                delay: const Duration(milliseconds: 200),
                child: _buildSecurityNote(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceHeader(AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.availableBalance, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontFamily: 'Cairo')),
              const SizedBox(height: 4),
              Text('1,250,000 ${l10n.dzd}', style: TextStyle(color: colors.goldAccent, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ],
          ),
          Icon(Icons.account_balance_wallet_rounded, color: colors.goldAccent, size: 32),
        ],
      ),
    );
  }

  Widget _buildWithdrawForm(AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.amount, style: TextStyle(fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: adminFieldDecoration(context, l10n.withdrawAmountHint, Icons.payments_outlined),
          ),
          const SizedBox(height: 20),
          Text(l10n.ccpNumber, style: TextStyle(fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ccpController,
            keyboardType: TextInputType.number,
            decoration: adminFieldDecoration(context, l10n.ccpNumberHint, Icons.account_balance_rounded),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleWithdraw(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusAmberBg, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.statusAmberFg, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.withdrawSecurityNote,
              style: const TextStyle(fontSize: 12, color: AppColors.statusAmberFg, fontFamily: 'Cairo', height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
