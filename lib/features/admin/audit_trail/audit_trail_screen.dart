import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/shared/widgets/responsive_layout.dart';
import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../dashboard/admin_providers.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/widgets/portal_layout.dart';
import 'package:go_router/go_router.dart';

class AuditTrailScreen extends ConsumerStatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  ConsumerState<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends ConsumerState<AuditTrailScreen> {
  static const int _navIdx = 2; // Audit is index 2 in bottom nav (Dashboard, Commission, Legal, Settings)

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auditAsync = ref.watch(auditLogsStreamProvider);
    final colors = context.colors;
    final isMobile = ResponsiveLayout.isMobile(context);

    final menuItems = [
      (Icons.dashboard_rounded, l10n.dashboard, '/admin/dashboard'),
      (Icons.auto_graph_rounded, l10n.commissionsAdmin, '/admin/commission'),
      (Icons.history_edu_rounded, l10n.legalRecord, '/admin/audit'),
      (Icons.manage_accounts_rounded, l10n.userManagement, '/admin/users'),
      (Icons.settings_rounded, l10n.settingsAdmin, '/admin/settings'),
    ];

    final bottomNavBar = BottomNavigationBar(
      currentIndex: _navIdx,
      onTap: (idx) => context.go(menuItems[idx == 3 ? 4 : idx].$3), // Map index 3 to Settings
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(menuItems[0].$1), label: menuItems[0].$2),
        BottomNavigationBarItem(icon: Icon(menuItems[1].$1), label: menuItems[1].$2),
        BottomNavigationBarItem(icon: Icon(menuItems[2].$1), label: menuItems[2].$2),
        BottomNavigationBarItem(icon: Icon(menuItems[4].$1), label: menuItems[4].$2), // Settings
      ],
    );

    return PortalLayout(
      selectedIndex: 2, // Legal Record is index 2 in Sidebar
      menuItems: menuItems,
      portalTitle: isMobile ? l10n.legalRecord : l10n.adminPortal,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/admin/dashboard',
      topHeader: l10n.masterConsole,
      appBarColor: isMobile ? const Color(0xFF1E3A34) : null,
      appBarTextColor: isMobile ? Colors.white : null,
      bottomNavigationBar: isMobile ? bottomNavBar : null,
      appBarActions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.download_rounded, size: 16, color: isMobile ? Colors.white : colors.primary),
            label: Text(
              l10n.exportToPdf,
              style: TextStyle(color: isMobile ? Colors.white : colors.primary, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(
              backgroundColor: isMobile ? Colors.white.withValues(alpha: 0.1) : colors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
      body: _buildMainContent(context, l10n, auditAsync, isMobile),
    );
  }

  Widget _buildMainContent(BuildContext context, AppLocalizations l10n, AsyncValue auditAsync, bool isMobile) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Container(
            color: const Color(0xFF1E3A34),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.transactionsLog,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.auditLogSubtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.transactionsLog,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colors.onSurface, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.auditLogSubtitle,
                  style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: 16),
          child: Row(
            children: [
              _buildFilterChip(l10n.actionType, Icons.keyboard_arrow_down_rounded, isMobile),
              const SizedBox(width: 8),
              _buildFilterChip(l10n.timeRange, Icons.date_range_rounded, isMobile),
              const SizedBox(width: 8),
              _buildFilterChip(l10n.portal, Icons.keyboard_arrow_down_rounded, isMobile),
            ],
          ),
        ),

        // Audit List
        Expanded(
          child: auditAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noLogsFound,
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: 8).copyWith(bottom: 32),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildAuditItem(context, log, isMobile);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('${l10n.unexpectedError}: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isMobile) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.onSurface),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildAuditItem(BuildContext context, dynamic log, bool isMobile) {
    final colors = context.colors;
    Color statusColor = colors.primary;
    if (log.statusColor == 'accepted') statusColor = AppColors.accepted;
    if (log.statusColor == 'rejected') statusColor = AppColors.rejected;
    if (log.statusColor == 'subscriberFund') statusColor = AppColors.subscriberFund;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIconForAction(log.action),
              color: statusColor,
              size: isMobile ? 24 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: colors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      "${log.userName} • ${DateFormat('HH:mm').format(log.createdAt)}",
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(log.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getPortalFromAction(log.action),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPortalFromAction(String action) {
    // Simple logic to map actions to portals for visual demonstration based on mockups
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('employee') || lowerAction.contains('operator') || lowerAction.contains('وثيقة')) return "بوابة العمليات";
    if (lowerAction.contains('admin') || lowerAction.contains('مستخدم')) return "بوابة الإدارة";
    return "بوابة العملاء";
  }

  IconData _getIconForAction(String action) {
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('create') || lowerAction.contains('إضافة')) return Icons.add_circle_outline;
    if (lowerAction.contains('update') || lowerAction.contains('تحديث') || lowerAction.contains('مراجعة')) return Icons.edit_note;
    if (lowerAction.contains('delete') || lowerAction.contains('حذف')) return Icons.delete_outline;
    if (lowerAction.contains('login') || lowerAction.contains('دخول')) return Icons.login;
    if (lowerAction.contains('pay') || lowerAction.contains('دفع')) return Icons.payment;
    return Icons.history;
  }
}
