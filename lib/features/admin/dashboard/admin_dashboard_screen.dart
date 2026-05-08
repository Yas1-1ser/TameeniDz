import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/enums/policy_status.dart';
import 'admin_providers.dart';
import 'package:tameenidz/shared/widgets/portal_layout.dart';
import 'package:tameenidz/shared/widgets/responsive_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/realtime/realtime_manager.dart';
import '../../../core/realtime/realtime_status_badge.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  static const int _navIdx = 0; // Dashboard is index 0
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
          callback: (payload) {
            ref.invalidate(allPoliciesStreamProvider);
          },
        );
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'audit_logs',
          callback: (payload) {
            ref.invalidate(auditLogsStreamProvider);
          },
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
      portalTitle: isMobile ? l10n.dashboard : l10n.adminPortal,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      topHeader: l10n.masterConsole,
      appBarColor: isMobile ? const Color(0xFF1E3A34) : null,
      appBarTextColor: isMobile ? Colors.white : null,
      bottomNavigationBar: isMobile ? bottomNavBar : null,
      showBackButton: true,
      fallbackRoute: '/role',
      appBarActions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RealtimeStatusBadge(
              stateStream: _realtimeManager.stateStream,
              onRetry: _realtimeManager.retryNow,
            ),
          ),
        ),
        if (isMobile)
          _buildHeaderAction(
            Icons.notifications_active_rounded,
            () {},
            hasBadge: true,
            iconColor: Colors.white,
            bgColor: Colors.white.withValues(alpha: 0.1),
          )
        else
          _buildHeaderAction(
            Icons.notifications_active_rounded,
            () {},
            hasBadge: true,
            iconColor: colors.onSurfaceVariant,
            bgColor: colors.surfaceContainerHigh,
          ),
      ],
      body:
          isMobile
              ? _buildMobileContent(context, l10n, policiesAsync)
              : _buildDesktopContent(context, l10n, policiesAsync),
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

  Widget _buildDesktopContent(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue policiesAsync,
  ) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.performanceOverview,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.performanceOverviewSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                policiesAsync.when(
                  data: (policies) {
                    final activeCount =
                        policies
                            .where((p) => p.status == PolicyStatus.accepted)
                            .length;
                    final totalPremium = policies.fold<double>(
                      0.0,
                      (double sum, p) => sum + p.amount,
                    );
                    final pendingCount =
                        policies
                            .where(
                              (p) =>
                                  p.status == PolicyStatus.pending ||
                                  p.status ==
                                      PolicyStatus.modificationRequested,
                            )
                            .length;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildDesktopKpiCard(
                            context,
                            title: l10n.totalActivePolicies,
                            value: activeCount.toString(),
                            subtitle:
                                "$pendingCount ${l10n.requireImmediateReview}",
                            icon: Icons.verified_user_rounded,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDesktopKpiCard(
                            context,
                            title: l10n.totalPremiumsCollectedDzd,
                            value: NumberFormat.compact().format(totalPremium),
                            subtitle:
                                "+15% ${l10n.fromLastMonth}", // Mock trend
                            icon: Icons.payments_rounded,
                            color: AppColors.subscriberFund,
                          ),
                        ),
                      ],
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, stack) =>
                          Center(child: Text('${l10n.unexpectedError}: $err')),
                ),
                const SizedBox(height: 48),
                _buildRequestsMonitor(context, l10n, policiesAsync),
                const SizedBox(height: 48),
                _buildRecentAudit(context, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(32),
      height: 280,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              height: 1.1,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue policiesAsync,
  ) {
    final colors = context.colors;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Green Section background extension
                Container(
                  color: const Color(0xFF1E3A34),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: policiesAsync.when(
                    data: (policies) {
                      final activeCount =
                          policies
                              .where((p) => p.status == PolicyStatus.accepted)
                              .length;
                      final totalPremium = policies.fold<double>(
                        0.0,
                        (double sum, p) => sum + p.amount,
                      );
                      // Mocking some values for the UI
                      final usersCount = 2847;
                      final companiesCount = 2;

                      return GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 90,
                            ),
                        children: [
                          _mobileKpiCard(
                            l10n.totalUsersAdmin,
                            NumberFormat.compact().format(usersCount),
                            Icons.people_alt_rounded,
                          ),
                          _mobileKpiCard(
                            l10n.activeRequestsAdmin,
                            activeCount.toString(),
                            Icons.pending_actions_rounded,
                          ),
                          _mobileKpiCard(
                            l10n.takafulCompaniesCount,
                            companiesCount.toString(),
                            Icons.business_rounded,
                          ),
                          _mobileKpiCard(
                            l10n.totalRevenue,
                            "${NumberFormat.compact().format(totalPremium)} ${l10n.dzd}",
                            Icons.payments_rounded,
                          ),
                        ],
                      );
                    },
                    loading:
                        () => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    error:
                        (err, stack) => Center(
                          child: Text(
                            '${l10n.unexpectedError}: $err',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                  ),
                ),

                // Quick Access
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickAccess,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 110,
                            ),
                        children: [
                          _quickAccessBtn(
                            l10n.userManagement,
                            Icons.manage_accounts_rounded,
                            '/admin/users',
                            const Color(0xFFE8F5E9),
                            const Color(0xFF2E7D32),
                          ),
                          _quickAccessBtn(
                            l10n.commissionsAdmin,
                            Icons.auto_graph_rounded,
                            '/admin/commission',
                            const Color(0xFFFFF3E0),
                            const Color(0xFFEF6C00),
                          ),
                          _quickAccessBtn(
                            l10n.settingsAdmin,
                            Icons.settings_rounded,
                            '/client/settings',
                            const Color(0xFFF3E5F5),
                            const Color(0xFF6A1B9A),
                          ),
                          _quickAccessBtn(
                            l10n.legalRecord,
                            Icons.history_edu_rounded,
                            '/admin/audit',
                            const Color(0xFFE3F2FD),
                            const Color(0xFF1565C0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Requests Monitor
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildRequestsMonitor(
                    context,
                    l10n,
                    policiesAsync,
                    isMobile: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Latest Activities
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildRecentAudit(context, l10n, isMobile: true),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // System Status Footer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: colors.surfaceContainerLowest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accepted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.systemStatusNormal,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileKpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAccessBtn(
    String label,
    IconData icon,
    String route,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurfaceVariant,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAudit(
    BuildContext context,
    AppLocalizations l10n, {
    bool isMobile = false,
  }) {
    final colors = context.colors;
    final auditAsync = ref.watch(auditLogsStreamProvider);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMobile ? l10n.latestActivitiesAdmin : l10n.latestAuditLogs,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/admin/audit'),
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          auditAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.noLogsYet,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children:
                    logs.take(5).map((l) {
                      Color c = colors.primary;
                      if (l.action.toLowerCase().contains('upload'))
                        c = AppColors.accepted;
                      if (l.action.toLowerCase().contains('edit'))
                        c = AppColors.goldAccent;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: c,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.action,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${l.userName} • ${DateFormat('HH:mm').format(l.createdAt)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd').format(l.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsMonitor(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue policiesAsync, {
    bool isMobile = false,
  }) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentRequests,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              if (!isMobile)
                TextButton(
                  onPressed: () {}, // Link to a full list if available
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          policiesAsync.when(
            data: (policies) {
              if (policies == null || (policies as List).isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.noRequestsFound,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }

              // Sort by date descending
              final sortedPolicies = List.from(policies as List)
                ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
              final displayPolicies = sortedPolicies.take(5).toList();

              return Column(
                children:
                    displayPolicies
                        .map(
                          (p) => _buildRequestItem(context, p, isMobile, l10n),
                        )
                        .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context,
    dynamic policy,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to details (reusing operator detail screen for now as it's perfectly suited)
          final routePrefix =
              policy.operatorId == 'algeria_takaful' ? '/at' : '/ai';
          context.push('$routePrefix/application/${policy.id}');
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policy.applicantName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${policy.planName ?? 'Auto Takaful'} • ${DateFormat('MMM dd').format(policy.submittedAt)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(policy.status, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PolicyStatus status, AppLocalizations l10n) {
    Color color;
    String label;

    switch (status) {
      case PolicyStatus.accepted:
        color = AppColors.accepted;
        label = l10n.statusAccepted;
        break;
      case PolicyStatus.rejected:
        color = AppColors.rejected;
        label = l10n.statusRejected;
        break;
      case PolicyStatus.modificationRequested:
        color = AppColors.goldAccent;
        label = l10n.statusModReq;
        break;
      default:
        color = AppColors.subscriberFund;
        label = l10n.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
