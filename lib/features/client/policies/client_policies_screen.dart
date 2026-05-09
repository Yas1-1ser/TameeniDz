import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/shared/enums/policy_status.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/widgets/email_verification_banner.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/receipt_ticket.dart';
import 'policy_providers.dart';
import '../../shared/domain/models/policy_model.dart';
import 'package:tameenidz/shared/widgets/portal_layout.dart';

class ClientPoliciesScreen extends ConsumerWidget {
  const ClientPoliciesScreen({super.key});

  static const int _navIdx = 2; // Policies is index 2

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policiesAsync = ref.watch(clientPoliciesStreamProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return PortalLayout(
      selectedIndex: _navIdx,
      menuItems: menuItems,
      portalTitle: l10n.clientPortal,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
      body: _buildMainContent(context, policiesAsync, l10n),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    AsyncValue<List<PolicyModel>> policiesAsync,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    return Column(
      children: [
        const EmailVerificationBanner(),
        Expanded(
          child: policiesAsync.when(
            data: (policies) {
              if (policies.isEmpty) return _buildEmptyState(l10n, colors);
              return ListView.builder(
                padding: const EdgeInsets.all(32),
                itemCount: policies.length,
                itemBuilder:
                    (context, index) =>
                        _buildPolicyCard(context, policies[index], l10n),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, AppColorsExtension colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 64,
              color: colors.outlineVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noPoliciesFound,
            style: TextStyle(
              fontSize: 18,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context,
    PolicyModel policy,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    final dateStr = DateFormat.yMMMd().format(policy.submittedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.policyNumber}: ${policy.id.length > 8 ? policy.id.substring(0, 8).toUpperCase() : policy.id.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.submittedOn(dateStr),
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: policy.status),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: colors.surfaceContainerLowest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${NumberFormat.decimalPattern().format(policy.amount)} ${l10n.dzd}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (policy.status == PolicyStatus.accepted)
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => context.push(
                          '/client/payment/${policy.id}',
                          extra: policy.amount,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          l10n.payNow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    )
                  else if (policy.paidAt != null)
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ReceiptTicket(policy: policy),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: Text(
                        l10n.viewReceipt,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
