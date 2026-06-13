import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../../features/shared/widgets/email_verification_banner.dart';
import '../../../../features/shared/widgets/status_badge.dart';
import '../../../../features/shared/widgets/receipt_ticket.dart';
import 'policy_providers.dart';
import '../../shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/core/router/app_routes.dart';

// ── Provider: fetch national_id_url & proof_of_address_url from users table ──
final clientRegistrationDocsProvider = FutureProvider.autoDispose<Map<String, String?>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return {};
  final data = await supabase
      .from('users')
      .select('national_id_url, proof_of_address_url')
      .eq('id', userId)
      .maybeSingle();
  if (data == null) return {};
  return {
    'national_id_url': data['national_id_url'] as String?,
    'proof_of_address_url': data['proof_of_address_url'] as String?,
  };
});

class ClientPoliciesScreen extends ConsumerWidget {
  const ClientPoliciesScreen({super.key});

  static const int _navIdx = 2; // Policies is index 2

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.folder_shared_rounded, l10n.myDocuments, AppRoutes.myPolicies),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return DefaultTabController(
      length: 2,
      child: PortalLayout(
        selectedIndex: _navIdx,
        menuItems: menuItems,
        portalTitle: l10n.clientPortal,
        portalSubtitle: l10n.shariaInsurance,
        accentColor: colors.primary,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/client/plans'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          icon: const Icon(Icons.add_to_photos_rounded),
          label: Text(
            l10n.addNew,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
        ),
        body: Column(
          children: [
            const EmailVerificationBanner(),
            // ── Tab Bar ────────────────────────────────────────────────
            Container(
              color: colors.surface,
              child: TabBar(
                labelColor: colors.primaryGreen,
                unselectedLabelColor: colors.onSurfaceVariant,
                indicatorColor: colors.primaryGreen,
                labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: l10n.myRequests),
                  Tab(text: l10n.myPersonalDocuments),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ── Tab 1: Insurance Requests ──────────────────────
                  _RequestsTab(l10n: l10n),
                  // ── Tab 2: Personal Documents ──────────────────────
                  _PersonalDocsTab(l10n: l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Insurance Requests List ───────────────────────────────────────────
class _RequestsTab extends ConsumerWidget {
  final AppLocalizations l10n;
  const _RequestsTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policiesAsync = ref.watch(clientPoliciesStreamProvider);
    final colors = context.colors;

    return PageEntryAnimation(
      child: policiesAsync.when(
        data: (policies) {
          if (policies.isEmpty) return _buildEmptyState(l10n, colors);
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: policies.length,
            itemBuilder: (context, index) =>
                _buildPolicyCard(context, policies[index], l10n),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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
              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.warmDivider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.policyDetailPath(policy.id)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          color: colors.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.policyNumber}: ${policy.id.length > 8 ? policy.id.substring(0, 8).toUpperCase() : policy.id.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.submittedOn(dateStr),
                              style: TextStyle(
                                fontSize: 12,
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
                Divider(height: 1, color: colors.warmDivider.withValues(alpha: 0.5)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: colors.surfaceContainerLow.withValues(alpha: 0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.premium,
                              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                            ),
                            Text(
                              '${NumberFormat.decimalPattern().format(policy.amount)} ${l10n.dzd}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: colors.primaryGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (policy.status == PolicyStatus.accepted && policy.paidAt == null)
                        ElevatedButton(
                          onPressed: () => context.push('/client/payment/${policy.id}', extra: policy.amount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primaryGreen,
                            foregroundColor: colors.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            l10n.payNow,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Cairo', fontSize: 12),
                          ),
                        )
                      else if (policy.paidAt != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              icon: const Icon(Icons.receipt_long, size: 16),
                              label: Text(
                                l10n.viewReceipt,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primaryGreen,
                              ),
                            ),
                            if (policy.status == PolicyStatus.issued && policy.finalPolicyUrl != null) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(policy.finalPolicyUrl!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenFile)),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                label: Text(
                                  AppLocalizations.of(context)!.insuranceDocument,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.primaryGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab 2: Personal Documents ─────────────────────────────────────────────────
class _PersonalDocsTab extends ConsumerWidget {
  final AppLocalizations l10n;
  const _PersonalDocsTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(clientRegistrationDocsProvider);
    final colors = context.colors;

    return PageEntryAnimation(
      child: docsAsync.when(
        data: (docs) {
          final nationalIdUrl = docs['national_id_url'];
          final proofUrl = docs['proof_of_address_url'];
          final hasAny = nationalIdUrl != null || proofUrl != null;

          if (!hasAny) {
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
                      Icons.folder_off_outlined,
                      size: 56,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.noDocumentsYet,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header note
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.primaryGreen.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.primaryGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: colors.primaryGreen, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.personalDocsViewOnly,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: colors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (nationalIdUrl != null)
                _DocCard(
                  icon: Icons.badge_outlined,
                  title: l10n.nationalId,
                  subtitle: l10n.uploadNationalIdHint,
                  url: nationalIdUrl,
                  colors: colors,
                ),

              if (proofUrl != null) ...[
                const SizedBox(height: 16),
                _DocCard(
                  icon: Icons.home_outlined,
                  title: l10n.proofOfAddress,
                  subtitle: l10n.uploadProofOfAddressHint,
                  url: proofUrl,
                  colors: colors,
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorLoadingDocuments)),
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
  final AppColorsExtension colors;

  const _DocCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.warmDivider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.primaryGreen, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openUrl(context, url),
            icon: Icon(Icons.open_in_new_rounded, color: colors.primaryGreen),
            tooltip: AppLocalizations.of(context)!.openDocLink,
          ),
        ],
      ),
    );
  }

  void _openUrl(BuildContext context, String url) {
    // Uses go_router or url_launcher if available; fallback: show snackbar with URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(url, maxLines: 2, overflow: TextOverflow.ellipsis)),
    );
  }
}
