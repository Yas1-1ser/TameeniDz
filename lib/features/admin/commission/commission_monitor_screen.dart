import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/responsive_layout.dart';
import '../dashboard/admin_providers.dart';
import 'package:tameenidz/core/utils/commission_utils.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';

class CommissionMonitorScreen extends ConsumerStatefulWidget {
  const CommissionMonitorScreen({super.key});

  @override
  ConsumerState<CommissionMonitorScreen> createState() =>
      _CommissionMonitorScreenState();
}

class _CommissionMonitorScreenState
    extends ConsumerState<CommissionMonitorScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policiesAsync = ref.watch(allPoliciesStreamProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(context, l10n.commissionMonitoring),
      bottomNavigationBar: adminBottomNav(context, 1, l10n),
      body: policiesAsync.when(
        data: (policies) {
          final summary = ref.watch(commissionSummaryProvider(policies));
          final Map<String, double> companyPremiums = {
            'الجزائر للتكافل': 0.0,
            'الاتحاد': 0.0,
          };
          for (final p in policies) {
            final name = p.displayCompanyName;
            companyPremiums[name] = (companyPremiums[name] ?? 0) + p.amount;
          }

          return isMobile
              ? _buildMobileLayout(context, l10n, summary, companyPremiums, policies)
              : _buildDesktopLayout(context, l10n, summary, companyPremiums, policies);
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
            ),
        error:
            (err, stack) => Center(
              child: Text(
                '${l10n.unexpectedError}: $err',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(0xFFA03030),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations l10n,
    CommissionSummary summary,
    Map<String, double> companyPremiums,
    List<PolicyModel> policies,
  ) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now);

    return Column(
      children: [
        // Hero section with summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D1F0E), Color(0xFF4A3520)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalCommissionsMonthYear(
                    monthName,
                    now.year.toString(),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B7355),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${NumberFormat.compact().format(summary.totalCommission)} ${l10n.dzd}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D1F0E),
                    fontFamily: 'Cairo',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.adminShareLabel(NumberFormat.compact().format(summary.adminShare), l10n.dzd)} • '
                  '${l10n.operatorsShareLabel(NumberFormat.compact().format(summary.operatorShare), l10n.dzd)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B7355), fontFamily: 'Cairo'),
                ),
                Text(
                  '${l10n.newClientsCount(summary.newClientCount)} • ${l10n.returningClientsCount(summary.returningClientCount)}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF3A7D4E), fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyCommissionList(context, l10n, policies),
                const SizedBox(height: 20),
                Text(
                  l10n.companiesDetails,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D1F0E),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 12),
                ...companyPremiums.entries.map(
                  (e) => _buildCompanyCard(
                    context,
                    l10n,
                    e.key,
                    e.value,
                    summary.rate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    CommissionSummary summary,
    Map<String, double> companyPremiums,
    List<PolicyModel> policies,
  ) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hero card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D1F0E), Color(0xFF4A3520)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalCommissionsMonthYear(
                          monthName,
                          now.year.toString(),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.colors.surface.withValues(alpha: 0.8),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${NumberFormat.compact().format(summary.totalCommission)} ${l10n.dzd}",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: context.colors.surface,
                          fontFamily: 'Cairo',
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.sinceLastMonth,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.colors.surface,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  height: 180,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5DDD0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A96E).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFC9A96E),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.commissionsEvolution,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D1F0E),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        l10n.highestMonth,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7355),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$monthName ${now.year}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D1F0E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            l10n.platformCommission,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.adminShareLabel(NumberFormat.decimalPattern().format(summary.adminShare), l10n.dzd)} • '
            '${l10n.atAiShare(NumberFormat.decimalPattern().format(summary.operatorShare), l10n.dzd)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8B7355), fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 16),
          _buildPolicyCommissionList(context, l10n, policies),
          const SizedBox(height: 24),
          Text(
            l10n.companiesDetails,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D1F0E),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 150,
            ),
            itemCount: companyPremiums.length,
            itemBuilder: (context, index) {
              final entry = companyPremiums.entries.elementAt(index);
              return _buildCompanyCard(
                context,
                l10n,
                entry.key,
                entry.value,
                summary.rate,
                isDesktop: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    AppLocalizations l10n,
    String companyName,
    double premium,
    double rate, {
    bool isDesktop = false,
  }) {
    final commission = premium * rate;

    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_rounded,
                  color: Color(0xFF8B7355),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1F0E),
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.fromClientRate((rate * 100).toStringAsFixed(1)),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFC9A96E),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      l10n.newFullAdmin,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8B7355),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dueCommission,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B7355),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${NumberFormat.compact().format(commission)} ${l10n.dzd}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3A7D4E),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalPremiums,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B7355),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${NumberFormat.compact().format(premium)} ${l10n.dzd}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D1F0E),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCommissionList(
    BuildContext context,
    AppLocalizations l10n,
    List<PolicyModel> policies,
  ) {
    final recent = policies.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.requestsAndNin,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D1F0E),
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 10),
        ...recent.map((p) {
          final split = commissionSplitForPolicy(p, policies);
          final existing = isExistingClientForOperator(p, policies);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5DDD0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.applicantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        '${l10n.ninLabel}: ${p.nin ?? '—'}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8B7355), fontFamily: 'Cairo'),
                      ),
                      Text(
                        existing ? l10n.returningClient : l10n.newClient,
                        style: TextStyle(
                          fontSize: 10,
                          color: existing ? const Color(0xFF1B4F72) : const Color(0xFF3A7D4E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.adminShareLabel(split['admin']!.toStringAsFixed(0), l10n.dzd),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF3A7D4E),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    if (split['operator']! > 0)
                      Text(
                        l10n.atAiShare(split['operator']!.toStringAsFixed(0), l10n.dzd),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF8B7355), fontFamily: 'Cairo'),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
