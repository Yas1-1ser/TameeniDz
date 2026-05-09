import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../shared/domain/models/policy_model.dart';
import '../../shared/providers/operator_providers.dart';
import '../../admin/dashboard/admin_providers.dart';

class AdminApplicationDetailScreen extends ConsumerWidget {
  final String id;
  const AdminApplicationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyAsync = ref.watch(policyDetailStreamProvider(id));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.requestDetails,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            size: 24,
          ),
          onPressed: () => context.pop(),
          color: AppColors.onSurface,
        ),
      ),
      body: policyAsync.when(
        data: (policy) => _AdminDetailBody(policy: policy),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Text(
          l10n.adminReadOnlyView,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AdminDetailBody extends StatelessWidget {
  final PolicyModel policy;
  const _AdminDetailBody({required this.policy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: policy.status),
              Text(
                'ID: ${policy.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildInfoSection(context, l10n.subscriberInfo, [
            _buildInfoRow(l10n.fullName, policy.applicantName),
            _buildInfoRow(l10n.ninLabel, policy.applicantIdNumber ?? 'N/A'),
          ]),
          const SizedBox(height: 24),

          _buildInfoSection(context, l10n.insuranceInfo, [
            _buildInfoRow(l10n.policyType, policy.planName ?? 'Auto Takaful'),
            _buildInfoRow(
              l10n.totalAmount,
              '${NumberFormat.decimalPattern().format(policy.amount)} ${l10n.dzd}',
            ),
            _buildInfoRow(l10n.company, policy.displayCompanyName),
          ]),
          const SizedBox(height: 24),

          if (policy.adminNotes != null && policy.adminNotes!.isNotEmpty) ...[
            _buildInfoSection(context, l10n.decisionNotes, [
              Text(
                policy.adminNotes!,
                style: TextStyle(color: colors.onSurface, fontSize: 14),
              ),
            ]),
            const SizedBox(height: 24),
          ],

          if (policy.receiptUrl != null) ...[
            _buildSectionTitle(context, 'Payment Proof'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(policy.receiptUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (policy.receiptNumber != null)
              _buildInfoRow(l10n.paymentReceiptNumber, policy.receiptNumber!),
            if (policy.paidAt != null)
              _buildInfoRow(
                l10n.paymentDate,
                DateFormat('yyyy-MM-dd HH:mm').format(policy.paidAt!),
              ),
            const SizedBox(height: 24),
          ],

          _buildAuditTrail(context, l10n),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTrail(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.auditLog),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, _) {
            final auditAsync = ref.watch(auditLogsStreamProvider);
            return auditAsync.when(
              data: (logs) {
                final policyLogs =
                    logs
                        .where(
                          (l) => l.action.contains(policy.id.substring(0, 5)),
                        )
                        .toList();
                if (policyLogs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Center(
                      child: Text(
                        l10n.noLogsYet,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }
                return Column(
                  children: policyLogs.map((l) => _buildAuditItem(l)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuditItem(dynamic log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history_rounded,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${log.userName} • ${DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt)}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
