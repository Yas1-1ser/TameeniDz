import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/services/realtime_manager.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'admin_providers.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late final RealtimeManager _realtimeManager;

  @override
  void initState() {
    super.initState();
    _realtimeManager = RealtimeManager(
      supabase: Supabase.instance.client,
      channelName: 'public:admin_dashboard',
      onSetupChannel: (channel) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'policies',
          callback: (payload) => ref.invalidate(allPoliciesStreamProvider),
        );
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'audit_logs',
          callback: (payload) => ref.invalidate(auditLogsStreamProvider),
        );
      },
    );
    _realtimeManager.connect();
  }

  @override
  void dispose() {
    _realtimeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policiesAsync = ref.watch(allPoliciesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(
        context,
        l10n.dashboard,
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: l10n.totalWallet,
            icon: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFFC9A96E),
            ),
            onPressed: () => context.go(AppRoutes.adminWallet),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: adminBottomNav(context, 0, l10n),
      body: PageEntryAnimation(
        child: policiesAsync.when(
          data: (policies) {
            // Sort by submittedAt descending to show latest first
            final sortedPolicies = List<PolicyModel>.from(policies)
              ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

            final summary = ref.watch(commissionSummaryProvider(policies));
            final recentPolicies = sortedPolicies.take(5).toList();
            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);
            final requestsToday = sortedPolicies
                .where((p) => !p.submittedAt.isBefore(todayStart))
                .length;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context, l10n, summary, policies.length, requestsToday),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildChart1(context, l10n),
                        const SizedBox(height: 14),
                        _buildChart2(context, l10n),
                        const SizedBox(height: 14),
                        _buildQuickAccessGrid(context, l10n),
                        const SizedBox(height: 14),
                        _buildSalesList(context, l10n, recentPolicies),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.adminPortal} v1.0',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8B7355),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    AppLocalizations l10n,
    CommissionSummary summary,
    int totalPolicies,
    int requestsToday,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1F0E), Color(0xFF4A3520)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminPortal,
            style: TextStyle(
              color: const Color(0xFFC9A96E).withValues(alpha: 0.7),
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.welcomePrefix} ${l10n.generalManager} ✦',
            style: TextStyle(
              color: context.colors.surface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _statCard(
                context,
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.totalWallet,
                value: '${summary.totalPremium.toInt()} ${l10n.dzd}',
                sub: l10n.adminTotalSubscriptionsCollected,
              ),
              _statCard(
                context,
                icon: Icons.description_outlined,
                label: l10n.requestsToday,
                value: '$requestsToday',
                sub: l10n.totalPoliciesCount(totalPolicies),
              ),

              _statCard(
                context,
                icon: Icons.business_outlined,
                label: l10n.takafulCompaniesCount,
                value: '2',
                sub: l10n.activeAudited,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFC9A96E).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFFC9A96E).withValues(alpha: 0.25),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color(0xFFC9A96E), size: 20),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFFC9A96E).withValues(alpha: 0.7),
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: context.colors.surface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: context.colors.surface.withValues(alpha: 0.6),
              fontSize: 10,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 4),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFC9A96E),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1F0E),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    ),
  );

  Widget _buildChart1(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(l10n.performanceOverview),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalPremiumsCollectedDzd,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1F0E),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '2025',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B7355),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildLegendItem(l10n.totalPremium, const Color(0xFFC9A96E)),
                  const SizedBox(width: 12),
                  _buildLegendItem(
                    l10n.commissionsAdmin,
                    const Color(0xFF2D1F0E),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 600,
                    barGroups: [
                      _makeGroup(0, 320, 13),
                      _makeGroup(1, 410, 16),
                      _makeGroup(2, 380, 15),
                      _makeGroup(3, 500, 20),
                      _makeGroup(4, 460, 18),
                      _makeGroup(5, 540, 22),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget:
                              (v, _) => Text(
                                [
                                  l10n.monthJanuary,
                                  l10n.monthFebruary,
                                  l10n.monthMarch,
                                  l10n.monthApril,
                                  l10n.monthMay,
                                  l10n.monthJune,
                                ][v.toInt()],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF8B7355),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget:
                              (v, _) => Text(
                                '${v.toInt()}K',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF8B7355),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                          interval: 200,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine:
                          (_) => const FlLine(
                            color: Color(0xFFF0E8DC),
                            strokeWidth: 0.5,
                          ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8B7355),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroup(int x, double premiums, double commission) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: premiums,
          color: const Color(0xFFC9A96E),
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: commission,
          color: const Color(0xFF2D1F0E),
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildChart2(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(l10n.adminPolicyDistribution),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildLegendItem(l10n.categoryAuto, const Color(0xFFC9A96E)),
                  const SizedBox(width: 8),
                  _buildLegendItem(l10n.categoryTravel, const Color(0xFF2D1F0E)),
                  const SizedBox(width: 8),
                  _buildLegendItem(l10n.categoryHealth, const Color(0xFF8B7355)),
                  const SizedBox(width: 8),
                  _buildLegendItem(l10n.categoryProperties, const Color(0xFFE5DDD0)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                    sections: [
                      PieChartSectionData(
                        value: 45,
                        color: const Color(0xFFC9A96E),
                        title: '45%',
                        radius: 40,
                        titleStyle: TextStyle(
                          color: context.colors.surface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      PieChartSectionData(
                        value: 25,
                        color: const Color(0xFF2D1F0E),
                        title: '25%',
                        radius: 40,
                        titleStyle: TextStyle(
                          color: context.colors.surface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: const Color(0xFF8B7355),
                        title: '20%',
                        radius: 40,
                        titleStyle: TextStyle(
                          color: context.colors.surface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: const Color(0xFFE5DDD0),
                        title: '10%',
                        radius: 40,
                        titleStyle: const TextStyle(
                          color: Color(0xFF2D1F0E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(l10n.quickAccess),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: [
            _quickBtn(
              icon: Icons.assignment_outlined,
              label: l10n.legalRecord,
              route: AppRoutes.adminAudit,
            ),
            _quickBtn(
              icon: Icons.settings_outlined,
              label: l10n.settingsAdmin,
              route: AppRoutes.adminSettings,
            ),
            _quickBtn(
              icon: Icons.percent,
              label: l10n.commissionsAdmin,
              route: AppRoutes.adminCommission,
            ),
            _quickBtn(
              icon: Icons.manage_accounts_outlined,
              label: l10n.userManagement,
              route: AppRoutes.adminUsers,
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickBtn({
    required IconData icon,
    required String label,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFC9A96E), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2D1F0E),
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesList(
    BuildContext context,
    AppLocalizations l10n,
    List<PolicyModel> recentPolicies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(l10n.adminSalesListTitle),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        l10n.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF2D1F0E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        l10n.company,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF2D1F0E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.total,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF2D1F0E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.statusLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF2D1F0E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (recentPolicies.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n.adminNoSalesRegistered,
                      style: const TextStyle(
                        color: Color(0xFF8B7355),
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentPolicies.length,
                  separatorBuilder:
                      (_, __) => const Divider(
                        color: Color(0xFFF0E8DC),
                        height: 0.5,
                        thickness: 0.5,
                      ),
                  itemBuilder:
                      (_, i) => _salesListRow(
                        policy: recentPolicies[i],
                        l10n: l10n,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _salesListRow({
    required PolicyModel policy,
    required AppLocalizations l10n,
  }) {
    final name = policy.applicantName;
    final company = policy.displayCompanyName;
    final amountText = '${policy.amount.toInt()} ${l10n.dzd}';
    final status = PolicyModel.statusToString(policy.status);

    Color bg;
    Color fg;
    String statusText;

    switch (status) {
      case 'accepted':
      case 'paid':
        bg = const Color(0xFF3A7D4E).withValues(alpha: 0.1);
        fg = const Color(0xFF3A7D4E);
        statusText = l10n.accepted;
        break;
      case 'rejected':
        bg = const Color(0xFFA03030).withValues(alpha: 0.1);
        fg = const Color(0xFFA03030);
        statusText = l10n.rejected;
        break;
      default:
        bg = const Color(0xFFC9A96E).withValues(alpha: 0.1);
        fg = const Color(0xFFC9A96E);
        statusText = l10n.pendingState;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFF5F0E8),
                  child: Icon(Icons.person, size: 14, color: Color(0xFF8B7355)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1F0E),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              company,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B7355),
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amountText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1F0E),
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: fg,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
