import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../shared/domain/models/policy_model.dart';
import '../shared/providers/operator_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../shared/enums/policy_status.dart';
import '../../../shared/widgets/status_badge.dart';

class OperatorPoliciesScreen extends ConsumerStatefulWidget {
  final String company;
  const OperatorPoliciesScreen({super.key, required this.company});

  @override
  ConsumerState<OperatorPoliciesScreen> createState() => _OperatorPoliciesScreenState();
}

class _OperatorPoliciesScreenState extends ConsumerState<OperatorPoliciesScreen> {

  bool get _isAT => widget.company == 'algeria_takaful';
  Color get _accent => _isAT ? AppColors.primaryGreen : AppColors.alIttihadGreen;

  int get _bottomNavIdx {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('surplus')) return 1;
    if (location.contains('policies')) return 2;
    if (location.contains('settings') || location.contains('profile')) return 3;
    return 0;
  }
  String _searchQuery = '';
  PolicyStatus? _selectedStatus;

  StreamProvider<List<PolicyModel>> get _provider =>
      _isAT ? atPoliciesStreamProvider : aiPoliciesStreamProvider;

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(_provider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildPremiumHeader(context, l10n),
            _buildSearchAndFilters(l10n),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(_provider);
                },
                child: policiesAsync.when(
                  data: (policies) => _buildList(policies, l10n),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.policies,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: context.colors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: l10n.search,
              prefixIcon: Icon(Icons.search_rounded, color: _accent),
              filled: true,
              fillColor: context.colors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: context.colors.outlineVariant, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: context.colors.outlineVariant, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: _accent, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _filterChip(null, l10n.all),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.pending, l10n.statusPending),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.accepted, l10n.statusAccepted),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.modificationRequested, l10n.statusModReq),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.rejected, l10n.statusRejected),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _filterChip(PolicyStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _accent : context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? _accent : context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _accent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<PolicyModel> policies, AppLocalizations l10n) {
    var filtered = policies.where((p) => 
      p.applicantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.id.contains(_searchQuery)
    ).toList();

    if (_selectedStatus != null) {
      filtered = filtered.where((p) => p.status == _selectedStatus).toList();
    }

    if (filtered.isEmpty) {
      return Center(child: Text(l10n.noRequestsFound));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final policy = filtered[index];
        return _policyCard(policy, l10n);
      },
    );
  }

  Widget _policyCard(PolicyModel policy, AppLocalizations l10n) {
    final colors = context.colors;
    final statusColor = _getStatusColor(policy.status);
    final detailRoute = _isAT ? '/at/application' : '/ai/application';

    return GestureDetector(
      onTap: () => context.push('$detailRoute/${policy.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.description_rounded, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.applicantName,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.tag_rounded, size: 12, color: colors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            policy.id.substring(0, 12).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusBadge(policy.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.amountLabel,
                        style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${policy.amount.toStringAsFixed(0)} ${l10n.dzd}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: colors.onSurface),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.submittedAt,
                        style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(policy.submittedAt),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(PolicyStatus status) {
    return StatusBadge(status: status);
  }

  Color _getStatusColor(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.pending: return AppColors.pending;
      case PolicyStatus.accepted: return AppColors.accepted;
      case PolicyStatus.paid: return const Color(0xFF0097A7);
      case PolicyStatus.rejected: return AppColors.rejected;
      case PolicyStatus.modificationRequested: return AppColors.modRequested;
    }
  }


  Widget _buildBottomNav(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return BottomNavigationBar(
      currentIndex: _bottomNavIdx,
      onTap: (idx) {
        if (idx == _bottomNavIdx) return;
        if (idx == 0) context.go(_isAT ? '/at/dashboard' : '/ai/dashboard');
        if (idx == 1) context.go(_isAT ? '/at/surplus' : '/ai/surplus');
        if (idx == 3) context.go(_isAT ? '/at/settings' : '/ai/settings');
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _accent,
      unselectedItemColor: colors.onSurfaceVariant,
      backgroundColor: colors.surface,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.dashboard),
        BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_rounded), label: l10n.surplus),
        BottomNavigationBarItem(icon: const Icon(Icons.archive_outlined), label: l10n.policies),
        BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
      ],
    );
  }
}
