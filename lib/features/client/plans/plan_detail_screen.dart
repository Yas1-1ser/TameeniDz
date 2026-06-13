import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../shared/domain/models/plan_model.dart';
import '../../shared/data/plan_repository.dart';

class PlanDetailScreen extends ConsumerWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final planAsync = ref.watch(planDetailProvider(planId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.policyDetails,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: colors.primary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return Center(child: Text(l10n.noData));
          }
          return _buildContent(context, l10n, colors, plan);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${l10n.unexpectedError}: $err')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    AppColorsExtension colors,
    PlanModel plan,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final displayName = locale == 'ar' ? plan.companyName : plan.companyEn;
    final displayDesc = locale == 'ar' ? plan.descriptionAr : plan.coverage;
    final displayCategory = locale == 'ar' ? plan.categoryAr : plan.category;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  plan.operatorColor,
                  plan.operatorColor.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: plan.operatorColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Icon(plan.resolvedIcon, color: colors.goldAccent, size: 36),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.planCode,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onPrimary.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildHeaderInfo(colors, l10n.category, displayCategory),
                    const SizedBox(width: 24),
                    _buildHeaderInfo(
                      colors,
                      l10n.statusLabel,
                      plan.badgeAr.isNotEmpty ? plan.badgeAr : l10n.active,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${l10n.premium}: ${plan.premium} ${l10n.dzd}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.goldAccent,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description
          _buildSectionTitle(colors, l10n.description),
          const SizedBox(height: 12),
          Text(
            displayDesc,
            style: TextStyle(
              fontSize: 15,
              color: colors.onSurfaceVariant,
              height: 1.6,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 32),

          // Features / Table Data
          _buildSectionTitle(colors, l10n.insuranceInfo),
          const SizedBox(height: 16),
          _buildFeatureRow(context, l10n.donationRatio, plan.tabarruRate),
          _buildFeatureRow(context, l10n.surplusDistribution, plan.surplusRate),
          _buildFeatureRow(context, l10n.claimsProcessing, plan.claimsDuration),
          const SizedBox(height: 32),

          // Required Documents
          _buildSectionTitle(colors, l10n.documents),
          const SizedBox(height: 12),
          ...((locale == 'ar'
                  ? plan.documentsRequiredAr
                  : [
                      'National ID',
                      'Driver License',
                      'NIF (for businesses)'
                    ])
              .map((doc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: colors.goldAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            doc.trim(),
                            style: TextStyle(
                                fontSize: 14,
                                color: colors.onSurface,
                                fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList()),
          const SizedBox(height: 48),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                context.push('/quote-form', extra: plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryGreen,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: colors.primaryGreen.withValues(alpha: 0.4),
              ),
              child: Text(
                l10n.getAQuote,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo'),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(AppColorsExtension colors, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colors.primaryGreen,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildHeaderInfo(
      AppColorsExtension colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: colors.onPrimary.withValues(alpha: 0.7),
              fontFamily: 'Cairo'),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.onPrimary,
              fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  fontFamily: 'Cairo')),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                  fontSize: 14,
                  fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
