import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../shared/domain/models/surplus_model.dart';
import '../shared/providers/operator_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../shared/widgets/email_verification_banner.dart';

class OperatorSurplusScreen extends ConsumerStatefulWidget {
  final String company;
  const OperatorSurplusScreen({super.key, required this.company});

  @override
  ConsumerState<OperatorSurplusScreen> createState() => _OperatorSurplusScreenState();
}

class _OperatorSurplusScreenState extends ConsumerState<OperatorSurplusScreen> {
  final int _bottomNavIdx = 1;

  bool get _isAT => widget.company == 'algeria_takaful';
  Color get _accent => _isAT ? AppColors.primaryGreen : AppColors.alIttihadGreen;

  StreamProvider<List<SurplusQuarterModel>> get _provider =>
      _isAT ? atQuarterlySurplusProvider : aiQuarterlySurplusProvider;

  @override
  Widget build(BuildContext context) {
    final quarterlyAsync = ref.watch(_provider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const EmailVerificationBanner(),
            _buildBrandHeader(context),
            _buildHeader(context, l10n),
            Expanded(
              child: quarterlyAsync.when(
                data: (quarters) => _buildContent(context, quarters, l10n),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _accent,
        child: const Icon(Icons.add, color: Colors.white),
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
            _isAT ? l10n.algeriaTakaful.toUpperCase() : l10n.alIttihad.toUpperCase(),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            l10n.distributionLog,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SurplusQuarterModel> quarters, AppLocalizations l10n) {
    final totalSurplus = quarters.fold<double>(0, (sum, q) => sum + q.policyholdersFund + q.shareholdersFund);
    final totalBeneficiaries = quarters.length * 1247; // Mocking a number for visual parity

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSummaryCard(l10n, totalSurplus, totalBeneficiaries),
          const SizedBox(height: 24),
          _buildQuarterlyList(quarters, l10n),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n, double total, int beneficiaries) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalSurplus2024,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,###').format(total)} ${l10n.dzd}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.beneficiariesCount(NumberFormat('#,###').format(beneficiaries)),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterlyList(List<SurplusQuarterModel> quarters, AppLocalizations l10n) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quarters.length,
      itemBuilder: (context, index) {
        final q = quarters[index];
        return _quarterItem(q, l10n);
      },
    );
  }

  Widget _quarterItem(SurplusQuarterModel q, AppLocalizations l10n) {
    final colors = context.colors;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final title = isAr ? q.titleAr : q.titleEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _statusBadge(q.status, l10n),
            ],
          ),
          const Divider(height: 32),
          _infoRow(l10n.policyholdersFund, '${NumberFormat('#,###').format(q.policyholdersFund)} ${l10n.dzd}'),
          const SizedBox(height: 12),
          _infoRow(l10n.shareholdersFund, '${NumberFormat('#,###').format(q.shareholdersFund)} ${l10n.dzd}'),
          const SizedBox(height: 12),
          _infoRow(l10n.individualShare, '${NumberFormat('#,###').format(q.individualShare)} ${l10n.dzd}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                l10n.distributionDateLabel(DateFormat('dd MMM yyyy').format(q.distributionDate)),
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status, AppLocalizations l10n) {
    final isCompleted = status == 'completed';
    final color = isCompleted ? AppColors.accepted : AppColors.pending;
    final label = isCompleted ? l10n.accepted : l10n.pendingState;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
        BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.dashboard),
        BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_rounded), label: l10n.surplus),
        BottomNavigationBarItem(icon: const Icon(Icons.archive_outlined), label: l10n.policies),
        BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
      ],
    );
  }
}
