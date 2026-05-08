import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/enums/policy_status.dart';
import '../../shared/widgets/status_badge.dart';
import '../shared/providers/operator_providers.dart';
import '../shared/data/policy_repository.dart';
import '../shared/domain/models/policy_model.dart';
import '../../core/providers/service_providers.dart';

class OperatorApplicationDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String company; // 'algeria_takaful' or 'al_ittihad'

  const OperatorApplicationDetailScreen({
    super.key,
    required this.id,
    required this.company,
  });

  @override
  ConsumerState<OperatorApplicationDetailScreen> createState() =>
      _OperatorApplicationDetailScreenState();
}

class _OperatorApplicationDetailScreenState
    extends ConsumerState<OperatorApplicationDetailScreen> {
  final _reasonCtrl = TextEditingController();
  bool _showReason = false;
  bool _loading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Color get _accentColor =>
      widget.company == 'algeria_takaful'
          ? AppColors.primaryGreen
          : AppColors.alIttihadGreen;

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(policyDetailStreamProvider(widget.id));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              l10n.requestDetails,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.company == 'algeria_takaful' 
                  ? 'ALGERIA TAKAFUL' 
                  : 'AL-ITTIHAD TAKAFUL',
              style: TextStyle(
                color: _accentColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            size: 24,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(widget.company == 'algeria_takaful' ? '/at/dashboard' : '/ai/dashboard');
            }
          },
          color: AppColors.onSurface,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
      body: policyAsync.when(
        data: (policy) => _buildContent(policy, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: policyAsync.when(
        data: (policy) {
          final userProfileAsync = ref.watch(userProfileProvider);
          return userProfileAsync.when(
            data: (profile) {
              final isAdmin = profile?['role'] == 'admin';
              if (isAdmin) {
                return _buildAdminReadOnlyFooter(l10n);
              }
              return _buildBottomActions(policy, l10n);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => _buildBottomActions(policy, l10n),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(PolicyModel policy, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status & ID
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

          // Subscriber Card
          _buildSectionTitle(l10n.subscriberInfo),
          const SizedBox(height: 12),
          _buildClientInfoCard(policy, l10n),
          const SizedBox(height: 24),

          // Insurance Info
          _buildSectionTitle(l10n.insuranceInfo),
          const SizedBox(height: 12),
          _buildInsuranceDetailsGrid(policy, l10n),
          const SizedBox(height: 24),

          // Documents
          _buildSectionTitle(l10n.uploadedDocuments),
          const SizedBox(height: 12),
          _buildDocumentsSection(policy, l10n),
          const SizedBox(height: 24),

          // Timestamps
          _buildAuditSection(policy, l10n),
          const SizedBox(height: 32),

          // Decision Notes Field
          Consumer(
            builder: (context, ref, _) {
              final userProfileAsync = ref.watch(userProfileProvider);
              return userProfileAsync.when(
                data: (profile) {
                  final isAdmin = profile?['role'] == 'admin';
                  if (isAdmin) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.decisionNotes,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reasonCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.enterDecisionReason,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildClientInfoCard(PolicyModel policy, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: _accentColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy.applicantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIN: ${policy.applicantIdNumber ?? '---'}',
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _buildInsuranceDetailsGrid(PolicyModel policy, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildDetailRow(l10n.policyType, policy.type, Icons.category_rounded),
          const Divider(height: 24),
          _buildDetailRow(
            l10n.insurancePlan,
            policy.planName ?? 'Standard',
            Icons.verified_user_rounded,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            l10n.requestedAmount,
            '${policy.amount.toStringAsFixed(0)} ${l10n.dzd}',
            Icons.account_balance_wallet_rounded,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            l10n.applicationDate,
            DateFormat('dd MMM yyyy').format(policy.submittedAt),
            Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(PolicyModel policy, AppLocalizations l10n) {
    final docs = policy.documentUrls;
    if (docs == null || docs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.description_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              l10n.noDocuments,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doc = docs[index] as Map<String, dynamic>;
          final label = doc['label']?.toString() ?? 'Document';
          final url = doc['url']?.toString() ?? '';

          return Container(
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Icon(Icons.image_not_supported_rounded),
                            ),
                          )
                        : Container(color: AppColors.surfaceContainerLow),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.viewAction,
                          style: TextStyle(fontSize: 11, color: _accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuditSection(PolicyModel policy, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                l10n.lastUpdateDate(
                  DateFormat('yyyy-MM-dd | HH:mm').format(policy.submittedAt),
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (policy.adminNotes != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    policy.adminNotes!,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(PolicyModel policy, AppLocalizations l10n) {
    if (policy.status != PolicyStatus.pending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Text(
          l10n.decisionTaken,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // REJECT
          Expanded(
            child: _buildActionButton(
              label: l10n.reject,
              color: AppColors.rejected,
              icon: Icons.close_rounded,
              onPressed: () => _decide(PolicyStatus.rejected, l10n),
            ),
          ),
          const SizedBox(width: 12),
          // MODIFY
          Expanded(
            child: _buildActionButton(
              label: l10n.modify,
              color: AppColors.modRequested,
              icon: Icons.edit_note_rounded,
              onPressed: () => _decide(PolicyStatus.modificationRequested, l10n),
            ),
          ),
          const SizedBox(width: 12),
          // ACCEPT
          Expanded(
            child: _buildActionButton(
              label: l10n.accept,
              color: AppColors.accepted,
              icon: Icons.check_rounded,
              onPressed: () => _decide(PolicyStatus.accepted, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _decide(PolicyStatus decision, AppLocalizations l10n) async {
    // Only require reason for non-accepted decisions
    if (decision != PolicyStatus.accepted && _reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterDecisionReason)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ref
          .read(policyRepositoryProvider)
          .updatePolicyStatus(widget.id, decision, notes: _reasonCtrl.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.statusUpdateSuccess),
            backgroundColor: AppColors.accepted,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(widget.company == 'algeria_takaful' ? '/at/policies' : '/ai/policies');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.statusUpdateError}: $e'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildAdminReadOnlyFooter(AppLocalizations l10n) {
    return Container(
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
    );
  }
}
