import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import '../../shared/data/plan_repository.dart';
import '../../shared/domain/models/plan_model.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class PlanComparisonScreen extends ConsumerStatefulWidget {
  final String? policyId;
  const PlanComparisonScreen({super.key, this.policyId});

  @override
  ConsumerState<PlanComparisonScreen> createState() =>
      _PlanComparisonScreenState();
}

class _PlanComparisonScreenState extends ConsumerState<PlanComparisonScreen> {
  static const int _navIndex = 1;
  final Set<String> _selectedPlanIds = {};
  bool _showComparisonTable = false;

  void _togglePlanSelection(String planId) {
    setState(() {
      if (_selectedPlanIds.contains(planId)) {
        _selectedPlanIds.remove(planId);
      } else {
        if (_selectedPlanIds.length < 3) {
          _selectedPlanIds.add(planId);
        } else {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.maxPlansComparison)),
          );
        }
      }
      if (_selectedPlanIds.length < 2) {
        _showComparisonTable = false;
      }
    });
  }

  String _formatClaimsDuration(String raw) {
    // Normalize any legacy values to proper display
    final lower = raw.toLowerCase();
    if (lower.contains('72') || lower.contains('3 day') || lower.contains('12 أيام') || lower.contains('12')) {
      return 'يوم واحد كحد أقصى';
    }
    if (lower.contains('48')) return '6 ساعات';
    if (lower.contains('hours') || lower.contains('hour') || lower.contains('ساعة') || lower.contains('ساعات')) {
      return raw;
    }
    return raw;
  }

  void _navigateToQuoteForm(PlanModel plan) {
    context.push(AppRoutes.quoteForm, extra: plan);
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
      portalTitle: l10n.protectionPacks,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/client',
      body: PageEntryAnimation(
        child: Consumer(
          builder: (context, ref, child) {
            final plansAsync = ref.watch(plansStreamProvider);
            return plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noData,
                      style: TextStyle(fontFamily: 'Cairo', color: colors.onSurfaceVariant),
                    ),
                  );
                }

                if (_showComparisonTable && _selectedPlanIds.length >= 2) {
                  final selectedPlans = plans.where((p) => _selectedPlanIds.contains(p.id)).toList();
                  return _buildComparisonView(colors, l10n, selectedPlans);
                }

                return _buildSelectionView(colors, l10n, plans);
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.primaryGreen),
              ),
              error: (err, stack) => Center(
                child: Text('${l10n.unexpectedError}: $err'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectionView(AppColorsExtension colors, AppLocalizations l10n, List<PlanModel> plans) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.protectionPacks,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.primaryGreen,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.protectionPackSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 32),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isSelected = _selectedPlanIds.contains(plan.id);
              return _buildPlanCard(colors, l10n, plan, isSelected);
            },
          ),
          
          const SizedBox(height: 32),

          if (_selectedPlanIds.isNotEmpty)
            _buildComparisonBar(colors, l10n),

          const SizedBox(height: 40),
          _buildFooterInfo(colors, l10n),
        ],
      ),
    );
  }

  Widget _buildPlanCard(AppColorsExtension colors, AppLocalizations l10n, PlanModel plan, bool isSelected) {
    final locale = Localizations.localeOf(context).languageCode;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? colors.primaryGreen.withValues(alpha: 0.05) : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colors.primaryGreen : colors.warmDivider,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: plan.operatorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(plan.resolvedIcon, color: plan.operatorColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.companyName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface, fontFamily: 'Cairo'),
                    ),
                    Text(plan.planCode, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontFamily: 'Cairo')),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: colors.primaryGreen, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            locale == 'ar' ? plan.descriptionAr : plan.coverage,
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, height: 1.4, fontFamily: 'Cairo'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.annualPremium, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontFamily: 'Cairo')),
                  Text(
                    '${plan.premium} ${l10n.dzd}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.primaryGreen, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _togglePlanSelection(plan.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSelected ? colors.primaryGreen : colors.onSurface,
                    side: BorderSide(color: isSelected ? colors.primaryGreen : colors.warmDivider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    isSelected ? l10n.remove : l10n.addToCompare,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToQuoteForm(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryGreen,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(0, 48),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.selectPlan,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.comparisonList, style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.7), fontSize: 12, fontFamily: 'Cairo')),
                Text(
                  '${_selectedPlanIds.length} / 3 ${l10n.plans}',
                  style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: _selectedPlanIds.length >= 2 
                  ? () => setState(() => _showComparisonTable = true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.goldAccent,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.onPrimary.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 48),
              ),
              child: Text(
                _selectedPlanIds.length >= 2 ? l10n.startComparison : l10n.selectAtLeastTwo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(AppColorsExtension colors, AppLocalizations l10n, List<PlanModel> selectedPlans) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showComparisonTable = false),
                icon: Icon(Icons.arrow_back_rounded, color: colors.primaryGreen),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.comparePlans,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primaryGreen, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildComparisonTable(colors, l10n, selectedPlans),
          const SizedBox(height: 40),
          _buildFooterInfo(colors, l10n),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(AppColorsExtension colors, AppLocalizations l10n, List<PlanModel> plans) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.warmDivider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 100, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8), child: const SizedBox()),
                  ...plans.map((plan) => Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    decoration: BoxDecoration(
                      border: plan.isBestValue ? Border.all(color: colors.goldAccent, width: 2) : null,
                      color: plan.isBestValue ? colors.goldAccent.withValues(alpha: 0.05) : null,
                    ),
                    child: Column(
                      children: [
                        Icon(plan.resolvedIcon, color: plan.operatorColor, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          plan.companyName.isNotEmpty ? plan.companyName : l10n.takafulPlan,
                          style: TextStyle(color: plan.operatorColor, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Cairo'),
                          textAlign: TextAlign.center,
                        ),
                        if (plan.isBestValue)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: colors.goldAccent, borderRadius: BorderRadius.circular(8)),
                            child: Text(l10n.bestValue, style: TextStyle(color: colors.onPrimary, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                          ),
                      ],
                    ),
                  )),
                ],
              ),
              _buildComparisonRow(l10n.coverageAmount, plans.map((p) => '${p.coverage} ${l10n.dzd}').toList(), plans),
              _buildComparisonRow(l10n.annualPremium, plans.map((p) => '${p.premium} ${l10n.dzd}').toList(), plans, isPrice: true),
              _buildComparisonRow(l10n.donationRatio, plans.map((p) => p.tabarruRate).toList(), plans),
              _buildComparisonRow(l10n.surplusDistribution, plans.map((p) => p.surplusRate).toList(), plans),
              _buildComparisonRow(l10n.claimsProcessing, plans.map((p) => _formatClaimsDuration(p.claimsDuration)).toList(), plans),
              Row(
                children: [
                  Container(width: 100, padding: const EdgeInsets.all(8), child: const SizedBox()),
                  ...plans.map((plan) => Container(
                    width: 150,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => _navigateToQuoteForm(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan.operatorColor,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(l10n.selectPlan, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values, List<PlanModel> plans, {bool isPrice = false}) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.warmDivider))),
      child: Row(
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ...List.generate(values.length, (index) {
            final isBest = plans[index].isBestValue;
            return Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                border: isBest ? Border(left: BorderSide(color: colors.goldAccent, width: 2), right: BorderSide(color: colors.goldAccent, width: 2)) : null,
                color: isBest ? colors.goldAccent.withValues(alpha: 0.05) : null,
              ),
              child: Text(
                values[index],
                style: TextStyle(
                  fontWeight: isBest || isPrice ? FontWeight.bold : FontWeight.normal,
                  color: isPrice ? colors.primaryGreen : colors.onSurface,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, color: colors.goldAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.shariaApprovedNotice,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, height: 1.5, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
