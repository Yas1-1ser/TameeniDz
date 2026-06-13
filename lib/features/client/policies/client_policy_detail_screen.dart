import 'package:go_router/go_router.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/shared/data/policy_repository.dart';
import 'policy_providers.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientPolicyDetailScreen extends ConsumerStatefulWidget {
  final String policyId;
  const ClientPolicyDetailScreen({super.key, required this.policyId});

  @override
  ConsumerState<ClientPolicyDetailScreen> createState() => _ClientPolicyDetailScreenState();
}

class _ClientPolicyDetailScreenState extends ConsumerState<ClientPolicyDetailScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final policyId = widget.policyId;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final policyAsync = ref.watch(clientPoliciesStreamProvider);

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: colors.beigeBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.onSurface),
        title: Text(
          l10n.policyDetails,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colors.onSurface,
          ),
        ),
      ),
      body: policyAsync.when(
        data: (policies) {
          PolicyModel? policy;
          try {
            policy = policies.firstWhere((p) => p.id == policyId);
          } catch (_) {
            // Fallback: try prefix match for shortened IDs
            try {
              policy = policies.firstWhere((p) => p.id.startsWith(policyId));
            } catch (_) {
              policy = null;
            }
          }
          if (policy == null) {
            return Center(
              child: Text(
                l10n.noRequestsFound,
                style: TextStyle(color: colors.onSurface, fontFamily: 'Cairo'),
              ),
            );
          }
          return PageEntryAnimation(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(context, colors, l10n, policy),
                  const SizedBox(height: 24),
                  _buildModificationBanner(context, colors, policy),
                  _buildDetails(context, colors, l10n, policy),
                  const SizedBox(height: 32),
                  _buildActions(context, colors, l10n, policy),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
    PolicyModel policy,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryGreen, colors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                policy.planName ?? 'Standard Plan',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.verified_user_rounded, color: colors.onPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            policy.id.toUpperCase(),
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  colors,
                  l10n.statusLabel,
                  _getStatusLabel(l10n, policy.status),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _headerStat(
                  colors,
                  l10n.submittedAt,
                  DateFormat.yMMMd().format(policy.submittedAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(AppLocalizations l10n, PolicyStatus status) {
    switch (status) {
      case PolicyStatus.pending:
        return l10n.statusPending;
      case PolicyStatus.accepted:
        return l10n.statusAccepted;
      case PolicyStatus.paid:
        return l10n.statusPaid;
      case PolicyStatus.rejected:
        return l10n.statusRejected;
      case PolicyStatus.modificationRequested:
        return l10n.statusModReq;
      case PolicyStatus.insurancePending:
        return l10n.statusInsurancePending;
      case PolicyStatus.issued:
        return l10n.statusIssued;
    }
  }

  Widget _headerStat(AppColorsExtension colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onPrimary.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildModificationBanner(
    BuildContext context,
    AppColorsExtension colors,
    PolicyModel policy,
  ) {
    if (policy.status != PolicyStatus.modificationRequested)
      return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFECB5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF856404)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.modifyDocumentsRequest,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  policy.adminNotes ??
                      AppLocalizations.of(context)!.pleaseReuploadDocsAsRequested,
                  style: const TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
    PolicyModel policy,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _detailRow(colors, l10n.company, policy.displayCompanyName),
          _detailRow(
            colors,
            l10n.premium,
            '${NumberFormat.decimalPattern().format(policy.amount)} ${l10n.dzd}',
          ),
          if (policy.paidAt != null)
            _detailRow(
              colors,
              l10n.paymentDate,
              DateFormat.yMMMd().format(policy.paidAt!),
            ),
          _detailRow(
            colors,
            l10n.statusLabel,
            _getStatusLabel(l10n, policy.status),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(AppColorsExtension colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
    PolicyModel policy,
  ) {
    return Column(
      children: [
        // ── Operator has provided a quote/offer → client Accept / Refuse ──
        if (policy.status == PolicyStatus.accepted && policy.paidAt == null) ...[
          _actionButton(
            colors,
            Icons.check_circle_outline_rounded,
            l10n.payNow,
            () => context.push('/client/payment/${policy.id}', extra: policy.amount),
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _actionButton(
            colors,
            Icons.cancel_outlined,
            l10n.reject,
            () => _confirmRefuse(context, l10n, policy),
          ),
          const SizedBox(height: 12),
        ],

        // ── Modification requested by operator ────────────────────────────
        if (policy.status == PolicyStatus.modificationRequested) ...[
          _actionButton(
            colors,
            Icons.edit_document,
            AppLocalizations.of(context)!.editAndResubmitDocs,
            () {
              context.push('/client/policy-documents/${policy.id}');
            },
            isPrimary: true,
          ),
          const SizedBox(height: 12),
        ],

        // ── Download policy PDF ─────────────────────────────────────
        if (policy.finalPolicyUrl != null) ...[
          _actionButton(
            colors,
            Icons.file_download_outlined,
            l10n.downloadDossier,
            () async {
              final url = Uri.parse(policy.finalPolicyUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            isPrimary: true,
          ),
          const SizedBox(height: 12),
        ],

        // ── File a new claim (only after paid) ────────────────────────────
        if (policy.status == PolicyStatus.paid)
          _actionButton(colors, Icons.add_alert_rounded, l10n.fileNewClaim, () {
            context.push('/client/submit-claim', extra: {
              'policyId': policy.id,
              'planName': policy.planName,
              'operatorId': policy.operatorId,
            });
          }, isPrimary: false),
      ],
    );
  }

  void _confirmRefuse(BuildContext context, AppLocalizations l10n, PolicyModel policy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reject, style: const TextStyle(fontFamily: 'Cairo')),
        content: Text(
          l10n.confirmRefuseOffer,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                await ref.read(policyRepositoryProvider).rejectPolicyByClient(policy.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.offerRefusedSuccess)),
                  );
                  context.pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: Text(
              l10n.reject,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    AppColorsExtension colors,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : onTap,
        icon: Icon(
          icon,
          color: isPrimary ? colors.onPrimary : colors.primaryGreen,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: isPrimary ? colors.primaryGreen : Colors.transparent,
          foregroundColor: isPrimary ? colors.onPrimary : colors.primaryGreen,
          side:
              isPrimary
                  ? BorderSide.none
                  : BorderSide(color: colors.primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
