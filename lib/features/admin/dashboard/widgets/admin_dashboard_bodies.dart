import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'admin_stats_row.dart';
import 'admin_recent_applications.dart';
import 'admin_activity_feed.dart';

class DesktopBody extends StatelessWidget {
  final AsyncValue policiesAsync;
  final String operatorFilter;
  final ValueChanged<String> onFilterChanged;
  final AppLocalizations l10n;

  const DesktopBody({
    super.key,
    required this.policiesAsync,
    required this.operatorFilter,
    required this.onFilterChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
                _buildOperatorFilter(context, colors, l10n),
                const SizedBox(height: 32),
                policiesAsync.when(
                  data: (policies) => AdminStatsRow(
                    policies: policies,
                    operatorFilter: operatorFilter,
                    isMobile: false,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('${l10n.unexpectedError}: $err')),
                ),
                const SizedBox(height: 48),
                policiesAsync.when(
                  data: (policies) => AdminRecentApplications(
                    policies: policies,
                    operatorFilter: operatorFilter,
                    isMobile: false,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => const SizedBox(),
                ),
                const SizedBox(height: 48),
                _buildWalletCard(context),
                const SizedBox(height: 48),
                _buildSalesTable(context),
                const SizedBox(height: 48),
                const AdminActivityFeed(isMobile: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorFilter(BuildContext context, AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip(context, 'all', l10n.allOperators, Icons.business_rounded),
          _buildFilterChip(context, 'algeria_takaful', l10n.operatorTakafulTitle, Icons.shield_rounded),
          _buildFilterChip(context, 'al_ittihad', l10n.operatorIttihadTitle, Icons.verified_user_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label, IconData icon) {
    final isSelected = operatorFilter == value;
    final colors = context.colors;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? colors.primary : colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? colors.onSurface : colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1F0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.totalWallet, style: const TextStyle(color: Color(0xFF8B7355), fontSize: 13, fontFamily: 'Cairo')),
          const SizedBox(height: 4),
          Text('1,500,000 ${l10n.dzd}', style: const TextStyle(color: Color(0xFFC9A96E), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          const SizedBox(height: 4),
          Text(l10n.accumulatedCommissions, style: const TextStyle(color: Color(0xFF8B7355), fontSize: 11, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildSalesTable(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.salesTable, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1F0E), fontFamily: 'Cairo')),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.symmetric(inside: const BorderSide(color: Color(0xFFE5DDD0), width: 0.5)),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF5F0E8)),
                children: [
                  _buildTableCell(l10n.client, isHeader: true),
                  _buildTableCell(l10n.company, isHeader: true),
                  _buildTableCell(l10n.totalPremium, isHeader: true),
                  _buildTableCell(l10n.commission, isHeader: true),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell(l10n.mockClient1),
                  _buildTableCell(l10n.operatorTakafulTitle),
                  _buildTableCell('50,000 ${l10n.dzd}'),
                  _buildTableCell('5,000 ${l10n.dzd}'),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell(l10n.mockClient2),
                  _buildTableCell(l10n.operatorIttihadTitle),
                  _buildTableCell('30,000 ${l10n.dzd}'),
                  _buildTableCell('3,000 ${l10n.dzd}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF2D1F0E),
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class MobileBody extends StatelessWidget {
  final AsyncValue policiesAsync;
  final String operatorFilter;
  final AppLocalizations l10n;

  const MobileBody({
    super.key,
    required this.policiesAsync,
    required this.operatorFilter,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D1F0E), Color(0xFF4A3520)],
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: policiesAsync.when(
                    data: (policies) => AdminStatsRow(
                      policies: policies,
                      operatorFilter: operatorFilter,
                      isMobile: true,
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        '${l10n.unexpectedError}: $err',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
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
                          color: context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickAccessGrid(context, l10n),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: policiesAsync.when(
                    data: (policies) => AdminRecentApplications(
                      policies: policies,
                      operatorFilter: operatorFilter,
                      isMobile: true,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => const SizedBox(),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: AdminActivityFeed(isMobile: true),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildMobileFooter(context, l10n),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, AppLocalizations l10n) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 110,
      ),
      children: [
        _quickAccessBtn(context, l10n.userManagement, Icons.manage_accounts_rounded, '/admin/users', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
        _quickAccessBtn(context, l10n.commissionsAdmin, Icons.auto_graph_rounded, '/admin/commission', const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
        _quickAccessBtn(context, l10n.settingsAdmin, Icons.settings_rounded, '/client/settings', const Color(0xFFF3E5F5), const Color(0xFF6A1B9A)),
        _quickAccessBtn(context, l10n.legalRecord, Icons.history_edu_rounded, '/admin/audit', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      ],
    );
  }

  Widget _quickAccessBtn(BuildContext context, String label, IconData icon, String route, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.onSurfaceVariant, height: 1.1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFooter(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: colors.surfaceContainerLowest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(decoration: BoxDecoration(color: AppColors.accepted, shape: BoxShape.circle)),
          ),
          SizedBox(width: 8),
          Text(l10n.systemStatusNormal, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

