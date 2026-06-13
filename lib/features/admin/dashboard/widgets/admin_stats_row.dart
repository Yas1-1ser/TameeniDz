import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';

class AdminStatsRow extends StatelessWidget {
  final List<dynamic> policies;
  final String operatorFilter;
  final bool isMobile;

  const AdminStatsRow({
    super.key,
    required this.policies,
    required this.operatorFilter,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final filteredPolicies = operatorFilter == 'all'
        ? policies
        : policies.where((p) => p.operatorId == operatorFilter).toList();

    final activeCount = filteredPolicies
        .where((p) => p.status == PolicyStatus.accepted || p.status == PolicyStatus.paid)
        .length;
    final totalPremium = filteredPolicies.fold<double>(
      0.0,
      (double sum, p) => sum + p.amount,
    );
    final pendingCount = filteredPolicies
        .where((p) => p.status == PolicyStatus.pending || p.status == PolicyStatus.modificationRequested)
        .length;

    const usersCount = 2847;
    const companiesCount = 2;

    if (isMobile) {
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 90,
        ),
        children: [
          _mobileKpiCard(
            context,
            l10n.totalUsersAdmin,
            NumberFormat.compact().format(usersCount),
            Icons.people_alt_rounded,
          ),
          _mobileKpiCard(
            context,
            l10n.activeRequestsAdmin,
            activeCount.toString(),
            Icons.pending_actions_rounded,
          ),
          _mobileKpiCard(
            context,
            l10n.takafulCompaniesCount,
            companiesCount.toString(),
            Icons.business_rounded,
          ),
          _mobileKpiCard(
            context,
            l10n.totalRevenue,
            "${NumberFormat.compact().format(totalPremium)} ${l10n.dzd}",
            Icons.payments_rounded,
          ),
        ],
      );
    }

    final opName = operatorFilter == 'all'
        ? l10n.allOperators
        : (operatorFilter == 'algeria_takaful' ? l10n.operatorTakafulTitle : l10n.operatorIttihadTitle);

    return Row(
      children: [
        Expanded(
          child: _buildDesktopKpiCard(
            context,
            title: l10n.totalActivePolicies,
            value: activeCount.toString(),
            subtitle: "$pendingCount ${l10n.requireImmediateReview} • $opName",
            icon: Icons.verified_user_rounded,
            color: const Color(0xFFC9A96E),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopKpiCard(
            context,
            title: l10n.totalPremiumsCollectedDzd,
            value: NumberFormat.compact().format(totalPremium),
            subtitle: "+15% ${l10n.fromLastMonth} • $opName",
            icon: Icons.payments_rounded,
            color: const Color(0xFF2D1F0E),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1F0E),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileKpiCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.surface,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
