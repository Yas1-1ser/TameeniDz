import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/constants/app_colors.dart';
import 'package:tameenidz/shared/widgets/portal_layout.dart';
import '../../../core/providers/service_providers.dart';
import '../../shared/data/policy_repository.dart';
import '../../shared/domain/models/policy_model.dart';
import '../../../shared/enums/policy_status.dart';

class PlanComparisonScreen extends ConsumerStatefulWidget {
  const PlanComparisonScreen({super.key});
  @override
  ConsumerState<PlanComparisonScreen> createState() =>
      _PlanComparisonScreenState();
}

class _PlanComparisonScreenState extends ConsumerState<PlanComparisonScreen> {
  static const int _navIndex = 1;
  bool _isSubmitting = false;

  Future<void> _handlePlanSelection(
    String operatorId,
    String planId,
    double amount,
    String planName,
  ) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to continue')),
        );
        return;
      }

      final policyData = {
        'client_id': user.id,
        'plan_id': planId,
        'operator_id': operatorId,
        'status': 'pending',
        'amount': amount,
        'submitted_at': DateTime.now().toIso8601String(),
        'plan_name': planName,
      };

      await ref.read(policyRepositoryProvider).createPolicy(policyData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request for $planName submitted successfully!')),
        );
        context.go('/client/policies');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return PortalLayout(
      selectedIndex: _navIndex,
      menuItems: menuItems,
      portalTitle: l10n.comparePlans,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/client',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.comparePlans,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.comparePlansSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: colors.slate500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildComparisonTable(colors, l10n),
            const SizedBox(height: 32),
            _buildFooterInfo(colors, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: const SizedBox(height: 80),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.goldAccent, width: 2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          const Icon(Icons.workspace_premium,
                              color: AppColors.primaryGreen, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            l10n.algeriaTakaful,
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined,
                            color: colors.slate500, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          l10n.alIttihad,
                          style: TextStyle(color: colors.slate700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Data rows
              _buildRow(l10n.coverageAmount, '10,000,000 ${l10n.dzd}', '8,000,000 ${l10n.dzd}',
                  isBoldAlgeria: true),
              _buildRow(l10n.annualPremium, '50,000 ${l10n.dzd}', '45,000 ${l10n.dzd}',
                  isBoldAlgeria: true),
              _buildRow(l10n.donationRatio, '80%', '85%'),
              _buildRow(l10n.surplusDistribution, '50%', '30%',
                  isBoldAlgeria: true, showTrending: true),
              _buildRow(l10n.claimsProcessing, '48 ${l10n.hours}', '72 ${l10n.hours}',
                  isBoldAlgeria: true, isGreenAlgeria: true),

              // Button Row
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.slate200)),
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: SizedBox()),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.goldAccent, width: 2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => _handlePlanSelection(
                            'algeria_takaful',
                            'algeria_takaful_premium',
                            50000,
                            l10n.algeriaTakaful,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 16),
                                  const SizedBox(width: 4),
                                  Text(l10n.selectPlan,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => _handlePlanSelection(
                            'al_ittihad',
                            'al_ittihad_basic',
                            45000,
                            l10n.alIttihad,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.slate200,
                            foregroundColor: colors.slate500,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(l10n.selectPlan,
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // "Best Value" Badge
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.bestValue,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String algeriaVal,
    String ittihadVal, {
    bool isBoldAlgeria = false,
    bool isGreenAlgeria = false,
    bool showTrending = false,
  }) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.slate200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                label,
                style: TextStyle(color: colors.slate500, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.goldAccent, width: 2),
                  right: BorderSide(color: AppColors.goldAccent, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showTrending)
                    const Icon(Icons.trending_up,
                        color: AppColors.goldAccent, size: 16),
                  if (showTrending) const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      algeriaVal,
                      style: TextStyle(
                        fontWeight: isBoldAlgeria
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isGreenAlgeria
                            ? AppColors.primaryGreen
                            : colors.darkText,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                ittihadVal,
                style: TextStyle(color: colors.slate500, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified, color: AppColors.goldAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.shariaApprovedNotice,
              style: TextStyle(
                color: colors.slate500,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
