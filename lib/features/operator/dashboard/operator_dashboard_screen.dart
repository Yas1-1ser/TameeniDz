import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/shared/widgets/portal_layout.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/enums/policy_status.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../shared/domain/models/policy_model.dart';
import '../../shared/providers/operator_providers.dart';
import '../../../shared/widgets/email_verification_banner.dart';

class OperatorDashboardScreen extends ConsumerStatefulWidget {
  final String company;

  const OperatorDashboardScreen({super.key, required this.company});

  @override
  ConsumerState<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState
    extends ConsumerState<OperatorDashboardScreen> {
  final int _bottomNavIdx = 0;
  String _activeFilter = 'all';

  bool get _isAT => widget.company == 'algeria_takaful';

  String _nameEn(BuildContext context) =>
      _isAT
          ? AppLocalizations.of(context)!.algeriaTakaful
          : AppLocalizations.of(context)!.alIttihad;

  Color get _accent =>
      _isAT ? AppColors.primaryGreen : AppColors.alIttihadGreen;

  StreamProvider<List<PolicyModel>> get _provider =>
      _isAT ? atPoliciesStreamProvider : aiPoliciesStreamProvider;

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(_provider);
    final l10n = AppLocalizations.of(context)!;

    final companyName = _isAT ? l10n.algeriaTakaful : l10n.alIttihad;

    return PortalLayout(
      selectedIndex: 0,
      portalTitle: companyName,
      portalSubtitle: l10n.dashboard,
      topHeader: 'PORTAL',
      accentColor: _accent,
      menuItems: [
        (
          Icons.dashboard_rounded,
          l10n.dashboard,
          _isAT ? '/at/dashboard' : '/ai/dashboard',
        ),
        (
          Icons.account_balance_wallet_rounded,
          l10n.surplus,
          _isAT ? '/at/surplus' : '/ai/surplus',
        ),
        (
          Icons.archive_outlined,
          l10n.policies,
          _isAT ? '/at/policies' : '/ai/policies',
        ),
        (
          Icons.person_outline,
          l10n.profile,
          _isAT ? '/at/settings' : '/ai/settings',
        ),
      ],
      bottomNavigationBar: _buildBottomNav(context, l10n),
      body: Column(
        children: [
          const EmailVerificationBanner(),
          // Removing _buildBrandHeader as PortalLayout handles branding
          _buildHeader(context, l10n),
          Expanded(
            child: policiesAsync.when(
              data: (apps) => _buildContent(context, apps, l10n),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: _accent.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.business_center_rounded, color: _accent, size: 16),
          const SizedBox(width: 8),
          Text(
            _isAT
                ? l10n.algeriaTakaful.toUpperCase()
                : l10n.alIttihad.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: _accent,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PORTAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final userAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.surfaceContainerHigh,
            child: Icon(Icons.person_outline, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: userAsync.when(
              data: (dbUser) {
                final authUser = Supabase.instance.client.auth.currentUser;
                final metadataName = authUser?.userMetadata?['full_name'] ?? authUser?.userMetadata?['fullName'];
                final name = metadataName ?? dbUser?['full_name'] ?? l10n.operatorRoleLabel;
                final empId = dbUser?['employee_id'] as String?;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (empId != null && empId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${l10n.employeeIdLabel}: $empId',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const SizedBox(height: 40),
              error: (_, __) => const SizedBox(),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colors.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PolicyModel> apps,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_provider);
        await ref.read(_provider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStats(apps, l10n),
            const SizedBox(height: 24),
            _buildFilterChips(l10n),
            const SizedBox(height: 16),
            _buildRequestList(_filtered(apps, _activeFilter), l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(List<PolicyModel> apps, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statCard(
            l10n.allRequests,
            '${apps.length}',
            Colors.blue,
            Icons.list_alt_rounded,
          ),
          const SizedBox(width: 12),
          _statCard(
            l10n.pendingState,
            '${apps.where((a) => a.status == PolicyStatus.pending).length}',
            AppColors.pending,
            Icons.timer_outlined,
          ),
          const SizedBox(width: 12),
          _statCard(
            l10n.accepted,
            '${apps.where((a) => a.status == PolicyStatus.accepted).length}',
            AppColors.accepted,
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final colors = context.colors;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(l10n.all, 'all'),
          _filterChip(l10n.pendingState, 'pending'),
          _filterChip(l10n.accepted, 'accepted'),
          _filterChip(l10n.rejected, 'rejected'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = _activeFilter == value;
    final colors = context.colors;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _accent : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isActive
                    ? _accent
                    : colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : colors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestList(List<PolicyModel> apps, AppLocalizations l10n) {
    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(l10n.noRequestsFound),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _requestItem(app, l10n);
      },
    );
  }

  Widget _requestItem(PolicyModel app, AppLocalizations l10n) {
    final colors = context.colors;
    final statusColor = _getStatusColor(app.status);
    final detailRoute = _isAT ? '/at/application' : '/ai/application';
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () => context.push('$detailRoute/${app.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: isRtl
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              app.applicantName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: app.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.requestId}: ${app.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                isRtl ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.pending:
        return AppColors.pending;
      case PolicyStatus.accepted:
        return AppColors.accepted;
      case PolicyStatus.rejected:
        return AppColors.rejected;
      case PolicyStatus.modificationRequested:
        return AppColors.modRequested;
    }
  }

  String _getStatusLabel(PolicyStatus status, AppLocalizations l10n) {
    switch (status) {
      case PolicyStatus.pending:
        return l10n.statusPending;
      case PolicyStatus.accepted:
        return l10n.statusAccepted;
      case PolicyStatus.rejected:
        return l10n.statusRejected;
      case PolicyStatus.modificationRequested:
        return l10n.statusModReq;
    }
  }

  List<PolicyModel> _filtered(List<PolicyModel> apps, String filter) {
    if (filter == 'all') return apps;
    if (filter == 'pending')
      return apps.where((a) => a.status == PolicyStatus.pending).toList();
    if (filter == 'accepted')
      return apps.where((a) => a.status == PolicyStatus.accepted).toList();
    if (filter == 'rejected')
      return apps.where((a) => a.status == PolicyStatus.rejected).toList();
    if (filter == 'modificationRequested')
      return apps.where((a) => a.status == PolicyStatus.modificationRequested).toList();
    return apps;
  }

  Widget _buildBottomNav(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return BottomNavigationBar(
      currentIndex: _bottomNavIdx,
      onTap: (idx) {
        if (idx == _bottomNavIdx) return;
        if (idx == 0) context.go(_isAT ? '/at/dashboard' : '/ai/dashboard');
        if (idx == 1) context.go(_isAT ? '/at/surplus' : '/ai/surplus');
        if (idx == 2) context.go(_isAT ? '/at/policies' : '/ai/policies');
        if (idx == 3) context.go(_isAT ? '/at/settings' : '/ai/settings');
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _accent,
      unselectedItemColor: colors.onSurfaceVariant,
      backgroundColor: colors.surface,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_filled),
          label: l10n.dashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance_wallet_rounded),
          label: l10n.surplus,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.archive_outlined),
          label: l10n.policies,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: l10n.profile,
        ),
      ],
    );
  }
}
