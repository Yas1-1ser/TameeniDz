// lib/features/operator/algerie_ittihadd/dashboard/ai_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
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
import 'package:tameenidz/features/operator/widgets/shared_info_cards.dart';
import 'widgets/ai_kpi_card.dart';
import 'widgets/ai_application_card.dart';
import 'widgets/ai_product_card.dart';
import 'widgets/ai_requests_chart.dart';
import 'widgets/ai_roadside_section.dart';
import 'widgets/ai_line_chart.dart';
import 'widgets/ai_bar_chart.dart';

class AlgerieIttihaddDashboardScreen extends ConsumerStatefulWidget {
  const AlgerieIttihaddDashboardScreen({super.key});

  @override
  ConsumerState<AlgerieIttihaddDashboardScreen> createState() =>
      _AlgerieIttihaddDashboardScreenState();
}

class _AlgerieIttihaddDashboardScreenState
    extends ConsumerState<AlgerieIttihaddDashboardScreen> {
  String _activeFilter = 'all';
  late final RealtimeManager _realtimeManager;

  @override
  void initState() {
    super.initState();
    _realtimeManager = RealtimeManager(
      supabase: Supabase.instance.client,
      channelName: 'public:operator_dashboard_al_ittihad',
      onSetupChannel: (channel) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'policies',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'operator_id',
            value: 'al_ittihad',
          ),
          callback: (payload) {
            ref.invalidate(aiPoliciesStreamProvider);
            if (mounted) {
              final String applicant =
                  payload.newRecord['applicant_full_name'] ?? AppLocalizations.of(context)!.clientLabel;
              if (payload.eventType == PostgresChangeEvent.insert) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.new_releases_rounded,
                          color: kGoldShimmer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.newPolicyRequestFrom(applicant),
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontWeight: FontWeight.bold,
                              color: kIvory,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: kGoldDeep,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusMd),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            }
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

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            width: 24,
            height: 2,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: kGoldDeep,
              borderRadius: BorderRadius.circular(1),
            ),
          )
        else
          const SizedBox(height: 6),
        Icon(icon),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final l10n = AppLocalizations.of(context)!;
    final filters = {
      'all': l10n.filterAll,
      'pending': l10n.filterPending,
      'accepted': l10n.filterApproved,
      'paid': l10n.filterPaid,
      'rejected': l10n.filterRejected,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters.entries.map((e) {
              final isSelected = _activeFilter == e.key;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (_) => setState(() => _activeFilter = e.key),
                  selectedColor: kGoldDeep,
                  backgroundColor: kParchment,
                  checkmarkColor: kIvory,
                  side: const BorderSide(color: kParchment, width: 1),
                  label: Text(
                    e.value,
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: isSelected ? kIvory : kInkMuted,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusSm),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(aiPoliciesStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kIvory,
        appBar: AppBar(
          backgroundColor: kIvory,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(bottom: BorderSide(color: kParchment, width: 1)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.algeriaUnitedTitle,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kGoldDeep,
                ),
              ),
              Text(
                l10n.takafulForIndividualsAndCompanies,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: kInkMuted,
                ),
              ),
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: kGoldDeep,
                  ),
                  onPressed: () => context.push(AppRoutes.aiNotifications),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: TextStyle(
                          color: context.colors.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            RealtimeStatusBadge(
              manager: _realtimeManager,
              onRetry: _realtimeManager.connect,
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: kParchment, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (idx) {
              if (idx == 0) return;
              if (idx == 1) context.go('/ai/surplus');
              if (idx == 2) context.go('/ai/policies');
              if (idx == 3) context.go('/ai/settings');
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: kIvory,
            selectedItemColor: kGoldDeep,
            unselectedItemColor: kInkFaint,
            selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 11),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_filled, true),
                label: l10n.dashboard,
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.account_balance_wallet_rounded,
                  false,
                ),
                label: l10n.surplus,
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.description_rounded, false),
                label: l10n.documents,
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.settings_rounded, false),
                label: l10n.settings,
              ),
            ],
          ),
        ),
        body: PageEntryAnimation(
          child: policiesAsync.when(
            loading:
                () => const Center(
                  child: CircularProgressIndicator(color: kGoldMid),
                ),
            error:
                (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.errorLoadingDataWithDetails(e.toString()),
                      style: GoogleFonts.ibmPlexSansArabic(color: kInk),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(aiPoliciesStreamProvider);
                  await ref.read(aiPoliciesStreamProvider.future);
                },
                color: kGoldMid,
                backgroundColor: kIvory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Decorative Gold Filigree Band
                      Container(
                        height: 3,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kIvory,
                              kGoldLight,
                              kGoldMid,
                              kGoldDeep,
                              kGoldMid,
                              kGoldLight,
                              kIvory,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── KPI CARDS ────────────────────────────────────
                            StaggeredListItem(
                              delay: const Duration(milliseconds: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AiKpiCard(
                                      label: l10n.aiTotalRequests,
                                      value: policies.length,
                                      icon: Icons.assignment_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AiKpiCard(
                                      label: l10n.filterPending,
                                      value: pending.length,
                                      icon: Icons.hourglass_top_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AiKpiCard(
                                      label: l10n.filterPaid,
                                      value: paid.length,
                                      icon: Icons.check_circle_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── CHARTS SECTION ───────────────────────────────
                            StaggeredListItem(
                              delay: const Duration(milliseconds: 60),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.performanceStats,
                                    style: GoogleFonts.amiri(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kGoldDeep,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const AiLineChart(),
                                  const SizedBox(height: 16),
                                  const AiBarChart(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Requests Analytics Charts ──────────────────
                            const AiRequestsChart(),

                            const SizedBox(height: 24),

                            // ── FILTER TABS ──────────────────────────────────
                            StaggeredListItem(
                              delay: const Duration(milliseconds: 220),
                              child: _buildFilterTabs(),
                            ),
                            const SizedBox(height: 16),

                            // ── APPLICATION LIST ─────────────────────────────
                            ...filtered.asMap().entries.map(
                              (e) => StaggeredListItem(
                                delay: Duration(milliseconds: 260 + e.key * 50),
                                child: AiApplicationCard(
                                  policy: e.value,
                                  onTap: () {
                                    context.push(
                                      '/ai/application/${e.value.id}',
                                    );
                                  },
                                ),
                              ),
                            ),

                            if (filtered.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.noRequestsCurrently,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      color: kInkMuted,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
