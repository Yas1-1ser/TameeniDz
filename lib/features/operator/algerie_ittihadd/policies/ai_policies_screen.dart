import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/providers/operator_providers.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/widgets/status_badge.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AiPoliciesScreen extends ConsumerStatefulWidget {
  const AiPoliciesScreen({super.key});

  @override
  ConsumerState<AiPoliciesScreen> createState() => _AiPoliciesScreenState();
}

class _AiPoliciesScreenState extends ConsumerState<AiPoliciesScreen> {
  String _searchQuery = '';
  PolicyStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(aiPoliciesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    final menuItems = [
      (
        Icons.dashboard_rounded,
        l10n.dashboard,
        '/ai/dashboard',
      ),
      (
        Icons.account_balance_wallet_rounded,
        l10n.surplus,
        '/ai/surplus',
      ),
      (
        Icons.archive_outlined,
        l10n.policies,
        '/ai/policies',
      ),
      (
        Icons.receipt_long_outlined,
        l10n.claims,
        '/ai/claims',
      ),
      (
        Icons.local_offer_outlined,
        l10n.manageOffers,
        '/ai/offers',
      ),
      (
        Icons.settings_outlined,
        l10n.settings,
        '/ai/settings',
      ),
    ];

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: PortalLayout(
        selectedIndex: 2,
        portalTitle: l10n.ittihadPortal,
        portalSubtitle: l10n.insurancePortalSubtitle,
        accentColor: kGoldDeep,
        appBarColor: kIvory,
        appBarTextColor: kGoldDeep,
        selectedItemColor: kGoldDeep,
        selectedItemBgColor: kCream,
        unselectedItemColor: kInkMuted,
        sidebarBgColor: kIvory,
        menuItems: menuItems,
        body: PageEntryAnimation(
          child: SafeArea(
            child: Column(
              children: [
                _buildPremiumHeader(l10n),
                _buildSearchAndFilters(l10n),
                Expanded(
                  child: RefreshIndicator(
                    color: kGoldDeep,
                    onRefresh: () async {
                      ref.invalidate(aiPoliciesStreamProvider);
                    },
                    child: policiesAsync.when(
                      data: (policies) => _buildList(policies, l10n),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: kGoldDeep),
                      ),
                      error: (err, _) => Center(
                        child: Text(
                          l10n.dataLoadingError(err.toString()),
                          style: GoogleFonts.ibmPlexSansArabic(color: kStatusRejected),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (idx) {
            if (idx == 0) context.go('/ai/dashboard');
            if (idx == 1) context.go('/ai/surplus');
            if (idx == 2) context.go('/ai/policies');
            if (idx == 3) context.go('/ai/settings');
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kGoldDeep,
          unselectedItemColor: kInkMuted,
          backgroundColor: kIvory,
          selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_filled),
              label: l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_rounded),
              label: l10n.surplus,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.archive_outlined),
              label: l10n.policies,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insurancePortalTitle,
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, curve: Curves.easeOut)
              .slideX(begin: -0.03, end: 0, duration: 500.ms),
          const SizedBox(height: 4),
          Text(
            l10n.insurancePortalSubtitle,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              color: kInkMuted,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 3,
            decoration: BoxDecoration(
              gradient: kGoldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .scaleX(begin: 0, end: 1, duration: 600.ms, delay: 200.ms, alignment: Alignment.centerLeft),
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
            style: GoogleFonts.ibmPlexSansArabic(color: kInk),
            decoration: InputDecoration(
              hintText: l10n.searchByNameOrIdHint,
              hintStyle: GoogleFonts.ibmPlexSansArabic(color: kInkFaint, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: kGoldDeep),
              filled: true,
              fillColor: kCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusMd),
                borderSide: const BorderSide(color: kParchment),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusMd),
                borderSide: const BorderSide(color: kParchment),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusMd),
                borderSide: const BorderSide(color: kGoldDeep, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _filterChip(null, l10n.all),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.pending, l10n.statusPending),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.insurancePending, l10n.newInsuranceRequestsFilter),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.accepted, l10n.statusAccepted),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.modificationRequested, l10n.statusModReq),
              const SizedBox(width: 8),
              _filterChip(PolicyStatus.rejected, l10n.statusRejected),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
          color: isSelected ? kGoldDeep : kCream,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? kGoldDeep : kParchment,
          ),
          boxShadow: isSelected ? [kCardShadow] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            color: isSelected ? kIvory : kInkMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<PolicyModel> policies, AppLocalizations l10n) {
    var filtered = policies.where((p) =>
        p.applicantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.nin ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (_selectedStatus != null) {
      filtered = filtered.where((p) => p.status == _selectedStatus).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.archive_outlined, size: 64, color: kParchment),
            const SizedBox(height: 12),
            Text(
              l10n.noRequestsFound,
              style: GoogleFonts.ibmPlexSansArabic(
                color: kInkMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final policy = filtered[index];
        return _policyCard(policy, l10n)
            .animate()
            .fadeIn(duration: 450.ms, delay: (60 * index).ms, curve: Curves.easeOut)
            .slideY(begin: 0.06, end: 0, duration: 450.ms, delay: (60 * index).ms);
      },
    );
  }

  Widget _policyCard(PolicyModel policy, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push('/ai/application/${policy.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(color: kParchment),
          boxShadow: [kCardShadow],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kIvory,
                    borderRadius: BorderRadius.circular(kRadiusSm),
                  ),
                  child: const Icon(Icons.description_rounded, color: kGoldDeep, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.applicantName,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kInk,
                        ),
                      ),
                      if (policy.nin != null && policy.nin!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.ninLabel}: ${policy.nin}',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kGoldDeep,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.tag_rounded, size: 12, color: kInkMuted),
                          const SizedBox(width: 4),
                          Text(
                            policy.id.substring(0, 12).toUpperCase(),
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: kInkMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: policy.status),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kIvory,
                borderRadius: BorderRadius.circular(kRadiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.amountLabel,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10,
                          color: kInkMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${policy.amount.toStringAsFixed(0)} د.ج',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: kGoldDeep,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.submittedAt,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10,
                          color: kInkMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        intl.DateFormat('dd/MM/yyyy').format(policy.submittedAt),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kInk,
                        ),
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
}
