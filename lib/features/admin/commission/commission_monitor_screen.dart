import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/portal_layout.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard/admin_providers.dart';

class CommissionMonitorScreen extends ConsumerStatefulWidget {
  const CommissionMonitorScreen({super.key});

  @override
  ConsumerState<CommissionMonitorScreen> createState() =>
      _CommissionMonitorScreenState();
}

class _CommissionMonitorScreenState
    extends ConsumerState<CommissionMonitorScreen> {
  static const int _navIdx = 1; // Commission is index 1

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policiesAsync = ref.watch(allPoliciesStreamProvider);
    final colors = context.colors;
    final isMobile = ResponsiveLayout.isMobile(context);

    final menuItems = [
      (Icons.dashboard_rounded, l10n.dashboard, '/admin/dashboard'),
      (Icons.auto_graph_rounded, l10n.commissionsAdmin, '/admin/commission'),
      (Icons.history_edu_rounded, l10n.legalRecord, '/admin/audit'),
      (Icons.manage_accounts_rounded, l10n.userManagement, '/admin/users'),
      (Icons.settings_rounded, l10n.settingsAdmin, '/admin/settings'),
    ];

    // Build the bottom navigation bar for mobile
    final bottomNavBar = BottomNavigationBar(
      currentIndex: _navIdx,
      onTap: (idx) {
        final targetIdx = idx == 3 ? 4 : idx;
        context.go(menuItems[targetIdx].$3);
      },
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(menuItems[0].$1),
          label: menuItems[0].$2,
        ),
        BottomNavigationBarItem(
          icon: Icon(menuItems[1].$1),
          label: menuItems[1].$2,
        ),
        BottomNavigationBarItem(
          icon: Icon(menuItems[2].$1),
          label: menuItems[2].$2,
        ),
        BottomNavigationBarItem(
          icon: Icon(menuItems[4].$1),
          label: menuItems[4].$2,
        ), // Settings
      ],
    );

    return PortalLayout(
      selectedIndex: _navIdx,
      menuItems: menuItems,
      portalTitle: isMobile ? l10n.commissionMonitoring : l10n.adminPortal,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/admin/dashboard',
      topHeader: l10n.masterConsole,
      appBarColor: isMobile ? const Color(0xFF1E3A34) : null,
      appBarTextColor: isMobile ? Colors.white : null,
      bottomNavigationBar: isMobile ? bottomNavBar : null,
      appBarActions:
          isMobile
              ? [
                _buildHeaderAction(
                  Icons.notifications_active_rounded,
                  () {},
                  hasBadge: true,
                  iconColor: Colors.white,
                  bgColor: Colors.white.withValues(alpha: 0.1),
                ),
              ]
              : [
                _buildHeaderAction(
                  Icons.notifications_active_rounded,
                  () {},
                  hasBadge: true,
                  iconColor: colors.onSurfaceVariant,
                  bgColor: colors.surfaceContainerHigh,
                ),
              ],
      body: _buildMainContent(context, l10n, policiesAsync),
    );
  }

  Widget _buildHeaderAction(
    IconData icon,
    VoidCallback onTap, {
    bool hasBadge = false,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: iconColor),
          style: IconButton.styleFrom(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (hasBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.rejected,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue policiesAsync,
  ) {
    return policiesAsync.when(
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

        return ResponsiveLayout.isMobile(context)
            ? _buildMobileLayout(context, l10n, summary, companyPremiums)
            : _buildDesktopLayout(context, l10n, summary, companyPremiums);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => Center(child: Text('${l10n.unexpectedError}: $err')),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations l10n,
    CommissionSummary summary,
    Map<String, double> companyPremiums,
  ) {
    final colors = context.colors;
    final now = DateTime.now();
    final monthFormat = DateFormat('MMMM'); // Or localized month array
    final monthName = monthFormat.format(now);

    return Column(
      children: [
        // Top Card Area
        Container(
          color: const Color(0xFF1E3A34),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${NumberFormat.compact().format(summary.totalCommission)} ${l10n.dzd}",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "+12% ${l10n.fromLastMonth}", // Mock trend
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accepted,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Details Section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.companiesDetails,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ...companyPremiums.entries.map(
                  (e) => _buildCompanyCard(
                    context,
                    l10n,
                    e.key,
                    e.value,
                    summary.rate,
                  ),
                ),
                const SizedBox(height: 24),
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
  ) {
    final colors = context.colors;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(32),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.onPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${NumberFormat.compact().format(summary.totalCommission)} ${l10n.dzd}",
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: colors.onPrimary,
                                letterSpacing: -2,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "+12% ${l10n.fromLastMonth}", // Mock trend
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        height: 240,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldAccent.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n.commissionsEvolution,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              l10n.highestMonth,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$monthName ${now.year}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
                Text(
                  l10n.companiesDetails,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    mainAxisExtent: 160,
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
          ),
        ),
      ],
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
    final colors = context.colors;
    final commission = premium * rate;

    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 16),
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                width: isDesktop ? 56 : 48,
                height: isDesktop ? 56 : 48,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.business_rounded,
                  color: colors.onSurfaceVariant,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.commissionRatePct((rate * 100).toStringAsFixed(0)),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
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
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${NumberFormat.compact().format(commission)} ${l10n.dzd}",
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accepted,
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
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${NumberFormat.compact().format(premium)} ${l10n.dzd}",
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
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
}
