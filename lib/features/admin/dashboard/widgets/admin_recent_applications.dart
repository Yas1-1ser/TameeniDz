import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';

class AdminRecentApplications extends StatelessWidget {
  final List<dynamic> policies;
  final String operatorFilter;
  final bool isMobile;

  const AdminRecentApplications({
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

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentRequests,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1F0E),
                  fontFamily: 'Cairo',
                ),
              ),
              if (!isMobile)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC9A96E),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredPolicies.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.noRequestsFound,
                  style: const TextStyle(
                    color: Color(0xFF8B7355),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            )
          else ...[
            Column(
              children: filteredPolicies
                  .take(5)
                  .map((p) => _buildRequestItem(context, p, isMobile, l10n))
                  .toList(),
            ),
          ]
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
    return InkWell(
      onTap: () => context.push('/admin/application/${policy.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFC9A96E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFFC9A96E),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policy.applicantName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1F0E),
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${policy.planName ?? l10n.unspecified} • ${DateFormat('MMM dd').format(policy.submittedAt)}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B7355),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D1F0E).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      policy.operatorId == 'algeria_takaful' ? l10n.operatorTakafulTitle : l10n.operatorIttihadTitle,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1F0E),
                        fontFamily: 'Cairo',
                      ),
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
        color = const Color(0xFFC9A96E); // Gold
        label = l10n.statusAccepted;
        break;
      case PolicyStatus.rejected:
        color = const Color(0xFF2D1F0E); // Dark Brown
        label = l10n.statusRejected;
        break;
      case PolicyStatus.modificationRequested:
        color = const Color(0xFF8B7355); // Mid Brown
        label = l10n.statusModReq;
        break;
      case PolicyStatus.pending:
        color = const Color(0xFF8B7355); // Mid Brown
        label = l10n.statusPending;
        break;
      case PolicyStatus.paid:
        color = const Color(0xFFC9A96E); // Gold
        label = l10n.statusPaid;
        break;
      case PolicyStatus.insurancePending:
        color = const Color(0xFF1565C0);
        label = l10n.insuranceRequest;
        break;
      case PolicyStatus.issued:
        color = const Color(0xFF1B5E20);
        label = l10n.statusIssued;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
