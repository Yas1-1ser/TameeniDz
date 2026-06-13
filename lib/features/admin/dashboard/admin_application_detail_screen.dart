import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import '../../shared/domain/models/policy_model.dart';
import '../../shared/data/policy_repository.dart';
import '../../shared/enums/policy_status.dart';
import '../../shared/providers/operator_providers.dart';
import 'admin_providers.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class AdminApplicationDetailScreen extends ConsumerWidget {
  final String id;
  const AdminApplicationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final policyAsync = ref.watch(policyDetailStreamProvider(id));
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: buildAdminAppBar(
        context, 
        l10n.requestDetails,
        actions: [
          IconButton(
            icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, color: colors.goldAccent),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: adminBottomNav(context, 0, l10n),
      body: policyAsync.when(
        data: (policy) {
          if (policy == null) {
            return Center(child: Text(l10n.noData, style: const TextStyle(fontFamily: 'Cairo')));
          }
          return _AdminDetailBody(policy: policy);
        },
        loading: () => Center(child: CircularProgressIndicator(color: colors.goldAccent)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(fontFamily: 'Cairo'))),
      ),
    );
  }
}

class _AdminDetailBody extends ConsumerStatefulWidget {
  final PolicyModel policy;
  const _AdminDetailBody({required this.policy});

  @override
  ConsumerState<_AdminDetailBody> createState() => _AdminDetailBodyState();
}

class _AdminDetailBodyState extends ConsumerState<_AdminDetailBody> {
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(PolicyStatus status) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(policyRepositoryProvider).updatePolicyStatus(
        widget.policy.id,
        status,
        notes: _noteController.text.trim(),
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.statusUpdatedSuccess, style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy = widget.policy;
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status Header ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context, PolicyModel.statusToString(policy.status), l10n),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.requestNumber,
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10, fontFamily: 'Cairo'),
                    ),
                    Text(
                      policy.id.substring(0, 8).toUpperCase(),
                      style: TextStyle(color: colors.darkText, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Subscriber Info ─────────────────────────────────────────
          _buildInfoSection(context, l10n.subscriberInfo, [
            _buildInfoRow(context, l10n.fullName, policy.applicantName),
            _buildInfoRow(context, l10n.ninLabel, policy.nin ?? 'N/A'),
          ]),
          const SizedBox(height: 16),

          // ── Policy Info ─────────────────────────────────────────────
          _buildInfoSection(context, l10n.insuranceInfo, [
            _buildInfoRow(context, l10n.policyType, policy.planName ?? l10n.insurancePlan),
            _buildInfoRow(context, l10n.totalAmount, '${NumberFormat.decimalPattern().format(policy.amount)} ${l10n.dzd}'),
            _buildInfoRow(context, l10n.company, policy.displayCompanyName),
            _buildInfoRow(context, l10n.applicationDate, DateFormat('yyyy-MM-dd').format(policy.submittedAt)),
          ]),
          const SizedBox(height: 24),

          // ── Payment Receipt ─────────────────────────────────────────
          if (policy.receiptUrl != null || policy.status == PolicyStatus.paid) ...[
            _buildSectionTitle(context, l10n.paymentReceiptTitle),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (policy.receiptUrl != null)
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Image.network(
                        policy.receiptUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: colors.beigeBg,
                          child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant, size: 48),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(context, l10n.paymentReceiptNumber, policy.receiptNumber ?? l10n.pendingState),
                        if (policy.paidAt != null)
                          _buildInfoRow(context, l10n.paymentDate, DateFormat('yyyy-MM-dd HH:mm').format(policy.paidAt!)),
                        const SizedBox(height: 10),
                        if (policy.receiptUrl != null)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {}, // Future: zoom/download
                              icon: const Icon(Icons.fullscreen_rounded),
                              label: Text(l10n.zoomReceipt, style: const TextStyle(fontFamily: 'Cairo')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.darkText,
                                side: BorderSide(color: colors.goldAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Admin Actions ───────────────────────────────────────────
          _buildSectionTitle(context, l10n.adminActions),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: l10n.addNoteHint,
                    hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: colors.onSurfaceVariant),
                    filled: true,
                    fillColor: colors.beigeBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: colors.goldAccent))
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus(PolicyStatus.accepted),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusGreenFg,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(l10n.accept, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus(PolicyStatus.modificationRequested),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.goldAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(l10n.modify, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _updateStatus(PolicyStatus.rejected),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.statusRedFg,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(l10n.rejectPermanently, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4, right: 4),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: colors.goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13, fontFamily: 'Cairo')),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.darkText, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, AppLocalizations l10n) {
    final colors = context.colors;
    Color bg;
    Color fg;
    String text;
    switch (status) {
      case 'accepted':
        bg = AppColors.statusGreenBg;
        fg = AppColors.statusGreenFg;
        text = l10n.accepted;
        break;
      case 'paid':
        bg = AppColors.statusGreenBg;
        fg = AppColors.statusGreenFg;
        text = l10n.statusPaid;
        break;
      case 'rejected':
        bg = AppColors.statusRedBg;
        fg = AppColors.statusRedFg;
        text = l10n.rejected;
        break;
      default:
        bg = AppColors.statusAmberBg;
        fg = AppColors.statusAmberFg;
        text = l10n.pendingState;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg, fontFamily: 'Cairo')),
    );
  }
}
