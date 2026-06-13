import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/widgets/status_badge.dart';
import 'package:tameenidz/features/shared/widgets/immutable_timestamp.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/services/notification_helper.dart';

class AiClaimsScreen extends ConsumerStatefulWidget {
  const AiClaimsScreen({super.key});

  @override
  ConsumerState<AiClaimsScreen> createState() => _AiClaimsScreenState();
}

class _AiClaimsScreenState extends ConsumerState<AiClaimsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamController<List<Map<String, dynamic>>> _streamController;
  StreamSubscription? _sub1;
  StreamSubscription? _sub2;

  List<Map<String, dynamic>> _latestClaims = [];
  List<Map<String, dynamic>> _latestPolicies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _initStreams();
  }

  void _initStreams() {
    final claimsStream = Supabase.instance.client
        .from('client_claims')
        .stream(primaryKey: ['id'])
        .eq('operator_id', 'al_ittihad')
        .order('created_at', ascending: false);

    final policiesStream = Supabase.instance.client
        .from('client_policies')
        .stream(primaryKey: ['id'])
        .eq('operator_id', 'al_ittihad')
        .order('created_at', ascending: false);

    void emitCombined() {
      final combined = [..._latestClaims, ..._latestPolicies];
      combined.sort((a, b) {
        final da = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.now();
        final db = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.now();
        return db.compareTo(da);
      });
      _streamController.add(combined);
    }

    _sub1 = claimsStream.listen((data) {
      _latestClaims = data.map((e) => {...e, '_source': 'legacy'}).toList();
      emitCombined();
    });

    _sub2 = policiesStream.listen((data) {
      final claimsOnly = data.where((e) => e['request_type'] == 'claim');
      _latestPolicies = claimsOnly.map((e) => {...e, '_source': 'wizard'}).toList();
      emitCombined();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sub1?.cancel();
    _sub2?.cancel();
    _streamController.close();
    super.dispose();
  }

  PolicyStatus _mapStatus(String? status) {
    if (status == 'accepted' || status == 'approved' || status == 'approved_paid') {
      return PolicyStatus.accepted;
    }
    if (status == 'rejected') return PolicyStatus.rejected;
    if (status == 'paid') return PolicyStatus.paid;
    if (status == 'modificationRequested') return PolicyStatus.modificationRequested;
    if (status == 'under_review') return PolicyStatus.pending;
    return PolicyStatus.pending;
  }

  Future<void> _updateClaimStatus(String id, String newStatus, String source, AppLocalizations l10n) async {
    try {
      final table = source == 'wizard' ? 'client_policies' : 'client_claims';
      await Supabase.instance.client
          .from(table)
          .update({'status': newStatus})
          .eq('id', id);

      // ── Notify client about claim decision ──
      try {
        final record = await Supabase.instance.client
            .from(table)
            .select('client_id, plan_name')
            .eq('id', id)
            .maybeSingle();
        final clientId = record?['client_id'] as String?;
        if (clientId != null) {
          NotificationHelper.notifyClientStatusChange(
            clientId: clientId,
            status: newStatus,
            policyId: id,
            planName: record?['plan_name'] as String?,
          );
        }
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'accepted' ? l10n.claimAcceptedMsg : l10n.claimRejectedMsg,
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            backgroundColor: newStatus == 'accepted' ? kStatusAccepted : kStatusRejected,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.claimUpdateError}: $e', style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: kStatusRejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        selectedIndex: 3,
        portalTitle: l10n.alIttihadPortal,
        portalSubtitle: l10n.claimsRequests,
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: kGoldDeep),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${l10n.claimErrorOccurred}: ${snapshot.error}',
                      style: GoogleFonts.ibmPlexSansArabic(color: kStatusRejected),
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildClaimsHeader(l10n),
                    if (items.isNotEmpty) _buildLineChartCard(items, l10n),
                    if (items.isNotEmpty) _buildTabBar(l10n),
                    Expanded(
                      child: items.isEmpty
                          ? _buildEmptyState(l10n)
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildClaimsList(items, l10n),
                                _buildClaimsList(items.where((e) => _mapStatus(e['status']) == PolicyStatus.pending).toList(), l10n),
                                _buildClaimsList(items.where((e) => _mapStatus(e['status']) == PolicyStatus.accepted).toList(), l10n),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2, // Highlight Policies / Claims
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

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kParchment),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: kGoldDeep,
          borderRadius: BorderRadius.circular(kRadiusMd),
        ),
        labelColor: kIvory,
        unselectedLabelColor: kInkMuted,
        labelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w500, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: l10n.filterAll),
          Tab(text: l10n.pending),
          Tab(text: l10n.completed),
        ],
      ),
    );
  }

  Widget _buildDocBtn(BuildContext context, String label, String url, IconData icon) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 90) / 2,
      child: OutlinedButton.icon(
        onPressed: () => _showDoc(context, label, url),
        icon: Icon(icon, size: 14, color: kGoldDeep),
        label: Text(label, style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: kGoldDeep), overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          side: const BorderSide(color: kGoldDeep),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showDoc(BuildContext context, String label, String url) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: kIvory,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: kInk)),
            const SizedBox(height: 16),
            if (url.endsWith('.pdf'))
              Text(l10n.openDocLink, style: GoogleFonts.ibmPlexSansArabic(color: kInkMuted))
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.contain, height: 280,
                  errorBuilder: (c, e, s) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(l10n.openDocLink, style: GoogleFonts.ibmPlexSansArabic()),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.closeDialog, style: GoogleFonts.ibmPlexSansArabic())),
          ]),
        ),
      ),
    );
  }

  Widget _buildClaimsHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.claimsRequests,
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          Text(
            l10n.claimProcessingSubtitle,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              color: kInkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(List<Map<String, dynamic>> items, AppLocalizations l10n) {
    final sorted = List<Map<String, dynamic>>.from(items)
      ..sort((a, b) {
        final da = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
        final db = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        return da.compareTo(db);
      });

    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final amt = double.tryParse((sorted[i]['amount'] ?? 0).toString()) ?? 0.0;
      spots.add(FlSpot(i.toDouble(), amt / 1000.0));
    }

    if (spots.length < 2) {
      spots.add(const FlSpot(0, 70));
      spots.add(const FlSpot(1, 140));
      spots.add(const FlSpot(2, 95));
      spots.add(const FlSpot(3, 230));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: kParchment),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.claimsChartTitle,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: kGoldDeep,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kGoldLight.withValues(alpha: 0.18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: kParchment,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noClaims,
            style: GoogleFonts.ibmPlexSansArabic(
              color: kInkMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsList(List<Map<String, dynamic>> items, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final status = _mapStatus(item['status']);
        final amt = double.tryParse((item['amount'] ?? 0).toString()) ?? 0.0;
        final id = item['id']?.toString() ?? '';
        final source = item['_source']?.toString() ?? 'legacy';

        return InkWell(
          onTap: () => context.push('/ai/claim/$id?source=$source'),
          borderRadius: BorderRadius.circular(kRadiusMd),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        item['client_name'] ?? l10n.alIttihadClient,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kInk,
                        ),
                      ),
                      if (source == 'wizard') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kGoldDeep.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.claimsSubmittedViaApp,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 10,
                              color: kGoldDeep,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                source == 'wizard' ? l10n.claimRequestWizardTitle : (item['claim_type'] ?? l10n.generalClaim),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: kInkMuted,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: kParchment, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImmutableTimestamp(
                    timestamp: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
                  ),
                  Text(
                    '${intl.NumberFormat('#,###').format(amt)} د.ج',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: kGoldDeep,
                    ),
                  ),
                ],
              ),
              Builder(builder: (context) {
                final metadata = item['metadata'];
                final documents = item['documents'];

                List<Widget> docButtons = [];

                if (documents is List && documents.isNotEmpty) {
                  for (var doc in documents) {
                    if (doc is Map) {
                      final title = doc['title']?.toString() ?? 'وثيقة';
                      final docUrl = doc['url']?.toString();
                      if (docUrl != null) {
                        docButtons.add(_buildDocBtn(context, title, docUrl, Icons.file_present_rounded));
                      }
                    }
                  }
                } else if (metadata is Map) {
                  final nationalIdUrl = metadata['national_id_url'] as String?;
                  final proofUrl = metadata['proof_of_address_url'] as String?;
                  if (nationalIdUrl != null) {
                    docButtons.add(_buildDocBtn(context, l10n.nationalIdCard, nationalIdUrl, Icons.badge_rounded));
                  }
                  if (proofUrl != null) {
                    docButtons.add(_buildDocBtn(context, l10n.proofOfResidence, proofUrl, Icons.home_rounded));
                  }
                }

                if (docButtons.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(l10n.clientDocuments, style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.bold, color: kInkMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: docButtons,
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: kParchment, height: 1),
                  ],
                );
              }),
              if (status == PolicyStatus.pending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateClaimStatus(id, 'accepted', source, l10n),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: Text(
                          l10n.acceptClaim,
                          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kStatusAccepted,
                          foregroundColor: kIvory,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kRadiusSm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateClaimStatus(id, 'rejected', source, l10n),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(
                          l10n.rejectClaim,
                          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kStatusRejected,
                          side: const BorderSide(color: kStatusRejected),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kRadiusSm),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ));
      },
    );
  }
}
