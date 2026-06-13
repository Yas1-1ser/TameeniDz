import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/router/route_arguments.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import '../../shared/data/policy_repository.dart';

class QuoteResultScreen extends ConsumerStatefulWidget {
  final QuoteResultArgs args;

  const QuoteResultScreen({super.key, required this.args});

  @override
  ConsumerState<QuoteResultScreen> createState() => _QuoteResultScreenState();
}

class _QuoteResultScreenState extends ConsumerState<QuoteResultScreen> {
  bool _isSubmitting = false;

  Future<void> _handleCheckout() async {
    if (_isSubmitting) return;

    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unauthenticatedError)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final policyData = {
        'client_id': user.id,
        'plan_id': widget.args.planName.toLowerCase().replaceAll(' ', '_'),
        'operator_id': widget.args.operatorCode,
        'status': 'pending',
        'amount': widget.args.calculatedPremium,
        'submitted_at': DateTime.now().toIso8601String(),
        'plan_name': widget.args.planName,
        'metadata': widget.args.formData,
      };

      final policy = await ref.read(policyRepositoryProvider).createPolicy(policyData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ticketSuccessMessage)),
        );
        // Navigate to payment screen with the real policy ID
        context.go('/client/payment/${policy.id}', extra: widget.args.calculatedPremium);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.primaryGreen,
        elevation: 0,
        title: Text(
          l10n.quoteResult,
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.onPrimary, fontFamily: 'Cairo'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.onPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/client');
            }
          },
        ),
      ),
      body: PageEntryAnimation(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Premium amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primaryGreen, colors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.shield_rounded, color: colors.onPrimary.withValues(alpha: 0.7), size: 48),
                  const SizedBox(height: 16),
                  Text(
                    widget.args.planName,
                    style: TextStyle(
                      fontSize: 18,
                      color: colors.onPrimary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.args.calculatedPremium.toStringAsFixed(0)} DZD',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    l10n.perYear,
                    style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.6), fontSize: 14, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: SpringButton(child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.goldAccent,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting 
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: colors.onPrimary, strokeWidth: 2))
                  : Text(
                      l10n.proceedToCheckout,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
              )),
            ),
          ],
        ),
      )),
    );
  }
}
