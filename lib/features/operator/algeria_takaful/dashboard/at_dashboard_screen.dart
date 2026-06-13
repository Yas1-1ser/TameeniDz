// lib/features/operator/algeria_takaful/dashboard/at_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/services/realtime_manager.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/features/shared/providers/operator_providers.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/features/shared/widgets/realtime/realtime_status_badge.dart';
import 'package:tameenidz/core/providers/notification_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'widgets/at_kpi_card.dart';
import 'widgets/at_application_card.dart';
import 'widgets/at_product_card.dart';
import 'widgets/at_requests_chart.dart';
import 'widgets/at_line_chart.dart';
import 'widgets/at_bar_chart.dart';
import 'package:tameenidz/core/theme/app_colors.dart';

class AlgeriaTakafulDashboardScreen extends ConsumerStatefulWidget {
  const AlgeriaTakafulDashboardScreen({super.key});

  @override
  ConsumerState<AlgeriaTakafulDashboardScreen> createState() =>
      _AlgeriaTakafulDashboardScreenState();
}

class _AlgeriaTakafulDashboardScreenState
    extends ConsumerState<AlgeriaTakafulDashboardScreen> {
  String _activeFilter = 'all';
  late final RealtimeManager _realtimeManager;

  @override
  void initState() {
    super.initState();
    _realtimeManager = RealtimeManager(
      supabase: Supabase.instance.client,
      channelName: 'public:operator_dashboard_algeria_takaful',
      onSetupChannel: (channel) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'policies',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'operator_id',
            value: 'algeria_takaful',
          ),
          callback: (payload) {
            ref.invalidate(atPoliciesStreamProvider);
          },
        );
      },
    );
    _realtimeManager.connect();
  }

  @override
  void dispose() {
    _realtimeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(atPoliciesStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          backgroundColor: AppColors.bgPage,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_rounded,
              color: AppColors.beigeGold,
              size: 20,
            ),
            onPressed: () => context.go('/role'),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'جزائر تكافل',
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              Text(
                l10n.takafulHalalNotice,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: AppColors.midBrown,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            RealtimeStatusBadge(
              manager: _realtimeManager,
              onRetry: _realtimeManager.connect,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkBrown,
                  ),
                  onPressed: () => context.push(AppRoutes.atNotifications),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.statusRedFg,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (idx) {
              if (idx == 0) return;
              if (idx == 1) context.go('/at/surplus');
              if (idx == 2) context.go('/at/policies');
              if (idx == 3) context.go('/at/settings');
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.beigeGold,
            unselectedItemColor: AppColors.midBrown,
            selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 11),
            elevation: 0,
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
                icon: const Icon(Icons.description_rounded),
                label: l10n.documents,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: l10n.settings,
              ),
            ],
          ),
        ),
        body: PageEntryAnimation(
          child: policiesAsync.when(
            loading:
                () => const Center(
                  child: CircularProgressIndicator(color: AppColors.beigeGold),
                ),
            error: (e, _) => Center(child: Text('${l10n.unexpectedError}: $e')),
            data: (policies) {
              final pending =
                  policies
                      .where((p) => p.status == PolicyStatus.pending)
                      .toList();
              final paid =
                  policies.where((p) => p.status == PolicyStatus.paid).toList();

              final filtered =
                  _activeFilter == 'all'
                      ? policies
                      : policies
                          .where((p) => p.status.name == _activeFilter)
                          .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. KPI CARDS ────────────────────────────────────
                    StaggeredListItem(
                      delay: const Duration(milliseconds: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AtKpiCard(
                              label: l10n.allRequests,
                              value: policies.length,
                              icon: Icons.assignment_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AtKpiCard(
                              label: l10n.statusPending,
                              value: pending.length,
                              icon: Icons.hourglass_top_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AtKpiCard(
                              label: l10n.statusPaid,
                              value: paid.length,
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── 2. CHARTS SECTION ───────────────────────────────
                    StaggeredListItem(
                      delay: const Duration(milliseconds: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.performanceStats,
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const AtLineChart(),
                          const SizedBox(height: 16),
                          const AtBarChart(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Requests Analytics Charts ─────────────────────────
                    const AtRequestsChart(),

                    const SizedBox(height: 24),

                    _buildFilterTabs(l10n),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            l10n.noRequestsFound,
                            style: GoogleFonts.ibmPlexSansArabic(
                              color: AppColors.midBrown,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder:
                            (context, index) => StaggeredListItem(
                              delay: Duration(milliseconds: index * 50),
                              child: AtApplicationCard(
                                policy: filtered[index],
                                onTap:
                                    () => context.push(
                                      '/at/application/${filtered[index].id}',
                                    ),
                              ),
                            ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumExpansionTile({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: GoogleFonts.amiri(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          iconColor: AppColors.beigeGold,
          collapsedIconColor: AppColors.beigeGold,
          childrenPadding: const EdgeInsets.all(20),
          children: children,
        ),
      ),
    );
  }

  Widget _buildReqRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.beigeGold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    final filters = {
      'all': l10n.all,
      'pending': l10n.statusPending,
      'accepted': l10n.accepted,
      'paid': l10n.statusPaid,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters.entries.map((e) {
              final isSelected = _activeFilter == e.key;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _activeFilter = e.key),
                  selectedColor: AppColors.darkBrown,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.ibmPlexSansArabic(
                    color: isSelected ? Colors.white : AppColors.midBrown,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.darkBrown
                            : AppColors.borderLight,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
      ),
    );
  }
}
