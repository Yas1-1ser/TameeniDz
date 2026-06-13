import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class MyClaimsScreen extends ConsumerStatefulWidget {
  const MyClaimsScreen({super.key});

  @override
  ConsumerState<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends ConsumerState<MyClaimsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data
  List<Map<String, dynamic>> _insuranceRequests = [];
  List<Map<String, dynamic>> _claimRequests = [];
  bool _loadingInsurance = true;
  bool _loadingClaims = true;
  String? _errorInsurance;
  String? _errorClaims;
  StreamSubscription<List<Map<String, dynamic>>>? _claimsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _insuranceSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _claimsSub?.cancel();
    _insuranceSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _loadClaimRequests();
    _loadInsuranceRequests();
  }

  /// Streams insurance/quote requests in real-time so status
  /// changes from operators appear instantly.
  void _loadInsuranceRequests() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _loadingInsurance = true;
      _errorInsurance = null;
    });

    _insuranceSub?.cancel();
    _insuranceSub = Supabase.instance.client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('client_id', user.id)
        .order('submitted_at', ascending: false)
        .listen(
      (data) {
        if (mounted) {
          setState(() {
            _insuranceRequests = List<Map<String, dynamic>>.from(data);
            _loadingInsurance = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _loadingInsurance = false;
            _errorInsurance = e.toString();
          });
        }
      },
    );
  }

  /// Streams claims in real-time so the stage progress bar
  /// updates instantly when the operator changes stage/status.
  void _loadClaimRequests() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _loadingClaims = true;
      _errorClaims = null;
    });

    _claimsSub?.cancel();
    _claimsSub = Supabase.instance.client
        .from('client_claims')
        .stream(primaryKey: ['id'])
        .eq('client_id', user.id)
        .order('created_at', ascending: false)
        .listen(
      (data) {
        if (mounted) {
          setState(() {
            _claimRequests = List<Map<String, dynamic>>.from(data);
            _loadingClaims = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _loadingClaims = false;
            _errorClaims = e.toString();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _ClaimsL10n(context);
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.folder_shared_rounded, l10n.myDocuments, AppRoutes.myPolicies),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return Scaffold(
      body: PortalLayout(
        selectedIndex: -1,
        menuItems: menuItems,
        portalTitle: l10n.myClaims,
        portalSubtitle: l10n.shariaInsurance,
        accentColor: AppColors.primaryGreen,
        showBackButton: true,
        body: PageEntryAnimation(
          child: Column(
            children: [
              // ── Action Buttons ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.request_quote_rounded,
                        label: l10n.quoteRequest,
                        color: AppColors.primaryGreen,
                        onTap: () => context.push(AppRoutes.quoteForm),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.shield_rounded,
                        label: l10n.newInsuranceRequest,
                        color: const Color(0xFF00695C),
                        onTap: () => context.push(AppRoutes.insuranceRequest),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.assignment_late_rounded,
                        label: l10n.newClaimRequest,
                        color: AppColors.goldAccent,
                        onTap: () => context.push(AppRoutes.claimRequest),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Tab Bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: colors.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_rounded, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.insuranceRequests,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_insuranceRequests.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              _CountBadge(
                                count: _insuranceRequests.length,
                                isSelected: _tabController.index == 0,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_late_rounded, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.claimRequests,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_claimRequests.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              _CountBadge(
                                count: _claimRequests.length,
                                isSelected: _tabController.index == 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Tab Content ────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInsuranceTab(l10n, colors),
                    _buildClaimsTab(l10n, colors),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Insurance Requests Tab ────────────────────────────────────────────────
  Widget _buildInsuranceTab(_ClaimsL10n l10n, AppColorsExtension colors) {
    if (_loadingInsurance) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }
    if (_errorInsurance != null) {
      return _buildError(l10n.errorLoadingData, _loadInsuranceRequests, colors);
    }
    if (_insuranceRequests.isEmpty) {
      return _buildEmpty(
        Icons.shield_outlined,
        l10n.noInsuranceRequests,
        colors,
      );
    }

    return RefreshIndicator(
      onRefresh: () async { _loadInsuranceRequests(); },
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _insuranceRequests.length,
        itemBuilder: (context, index) {
          final req = _insuranceRequests[index];
          return StaggeredListItem(
            delay: Duration(milliseconds: index * 50),
            child: _InsuranceRequestCard(
              request: req,
              l10n: l10n,
              colors: colors,
            ),
          );
        },
      ),
    );
  }

  // ── Claims Tab ────────────────────────────────────────────────────────────
  Widget _buildClaimsTab(_ClaimsL10n l10n, AppColorsExtension colors) {
    if (_loadingClaims) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }
    if (_errorClaims != null) {
      return _buildError(l10n.errorLoadingData, _loadClaimRequests, colors);
    }
    if (_claimRequests.isEmpty) {
      return _buildEmpty(
        Icons.assignment_turned_in_outlined,
        l10n.noClaimsYet,
        colors,
      );
    }

    return RefreshIndicator(
      onRefresh: () async { _loadClaimRequests(); },
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _claimRequests.length,
        itemBuilder: (context, index) {
          final claim = _claimRequests[index];
          return StaggeredListItem(
            delay: Duration(milliseconds: index * 50),
            child: _ClaimRequestCard(
              claim: claim,
              l10n: l10n,
              colors: colors,
            ),
          );
        },
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _buildEmpty(IconData icon, String message, AppColorsExtension colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry, AppColorsExtension colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.error),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: colors.onSurfaceVariant)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Button Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Count Badge
// ─────────────────────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _CountBadge({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.3) : AppColors.primaryGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppColors.primaryGreen,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Insurance Request Card
// ─────────────────────────────────────────────────────────────────────────────
class _InsuranceRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final _ClaimsL10n l10n;
  final AppColorsExtension colors;

  const _InsuranceRequestCard({
    required this.request,
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final id = request['id'] as String? ?? '';
    final planName = request['plan_name'] as String? ?? l10n.unknown;
    final status = request['status'] as String? ?? 'pending';
    final amount = (request['amount'] as num?)?.toDouble() ?? 0.0;
    final submittedAt = request['submitted_at'] as String?;
    final metadata = request['metadata'] as Map<String, dynamic>?;
    final requestType = metadata?['request_type'] as String? ?? 'insurance';

    DateTime? date;
    if (submittedAt != null) {
      date = DateTime.tryParse(submittedAt);
    }

    final displayId = id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

    return InkWell(
      onTap: () => context.push('/client/policies/$id'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '#$displayId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(status: status, l10n: l10n),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(requestType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(requestType),
                  color: _getTypeColor(requestType),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (date != null)
                      Text(
                        DateFormat('yyyy-MM-dd').format(date),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (amount > 0)
                Text(
                  '${NumberFormat.decimalPattern().format(amount)} ${l10n.dzd}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'quote':
        return Icons.request_quote_rounded;
      case 'insurance':
        return Icons.shield_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'quote':
        return AppColors.goldAccent;
      case 'insurance':
        return const Color(0xFF00695C);
      default:
        return AppColors.primaryGreen;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Claim Request Card
// ─────────────────────────────────────────────────────────────────────────────
class _ClaimRequestCard extends StatelessWidget {
  final Map<String, dynamic> claim;
  final _ClaimsL10n l10n;
  final AppColorsExtension colors;

  const _ClaimRequestCard({
    required this.claim,
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final id = claim['id'] as String? ?? '';
    final description = claim['description'] as String? ?? '';
    final metadata = claim['metadata'] as Map<String, dynamic>? ?? {};
    final location = metadata['location'] as String? ?? '';
    final status = claim['status'] as String? ?? 'pending';
    final stage = metadata['stage'] as int? ?? 1;
    final submittedAt = claim['submitted_at'] as String?;

    DateTime? date;
    if (submittedAt != null) {
      date = DateTime.tryParse(submittedAt);
    }

    final displayId = id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

    return InkWell(
      onTap: () => context.push('/client/claims/$id'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '#$displayId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.goldAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(status: status, l10n: l10n),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.car_crash_rounded,
                  color: AppColors.goldAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description.isNotEmpty
                          ? (description.length > 50
                              ? '${description.substring(0, 50)}...'
                              : description)
                          : l10n.claimRequest,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (location.isNotEmpty)
                      Text(
                        location,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (date != null)
                      Text(
                        DateFormat('yyyy-MM-dd').format(date),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stage progress indicator
          _ClaimStageIndicator(stage: stage, l10n: l10n),
        ],
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Claim Stage Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _ClaimStageIndicator extends StatelessWidget {
  final int stage;
  final _ClaimsL10n l10n;

  const _ClaimStageIndicator({required this.stage, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final stages = [
      l10n.stageReceived,
      l10n.stageExpertAssigned,
      l10n.stageRepairAuthorised,
    ];

    return Row(
      children: List.generate(stages.length, (i) {
        final done = i < stage;
        final active = i == stage - 1;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.15),
                  ),
                ),
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? AppColors.primaryGreen
                          : active
                              ? AppColors.goldAccent
                              : AppColors.primaryGreen.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: active ? Colors.white : AppColors.primaryGreen,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stages[i],
                    style: TextStyle(
                      fontSize: 8,
                      color: done || active
                          ? AppColors.primaryGreen
                          : context.colors.onSurfaceVariant,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  final _ClaimsL10n l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'accepted':
      case 'paid':
        color = AppColors.accepted;
        label = l10n.statusAccepted;
        break;
      case 'rejected':
        color = AppColors.rejected;
        label = l10n.statusRejected;
        break;
      case 'received':
        color = const Color(0xFF2196F3);
        label = l10n.statusReceived;
        break;
      case 'under_review':
        color = const Color(0xFF0D47A1);
        label = AppLocalizations.of(context)!.statusUnderReview;
        break;
      case 'insurance_pending':
        color = const Color(0xFF00695C);
        label = l10n.statusInsurancePending;
        break;
      case 'pending':
      default:
        color = AppColors.goldAccent;
        label = l10n.statusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// L10n Helper
// ─────────────────────────────────────────────────────────────────────────────
class _ClaimsL10n {
  final BuildContext context;
  _ClaimsL10n(this.context);

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String get homeNav => _l10n.homeNav;
  String get plansNav => _l10n.plansNav;
  String get myClaims => _l10n.myClaims;
  String get myDocuments => _l10n.myDocuments;
  String get legal => _l10n.legal;
  String get support => _l10n.support;
  String get settings => _l10n.settings;
  String get shariaInsurance => _l10n.shariaInsurance;
  String get noClaimsYet => _l10n.noClaimsYet;
  String get dzd => _l10n.dzd;
  String get errorLoadingData => _l10n.errorLoadingData;
  String get unknown => _l10n.unknown;

  // New keys
  String get insuranceRequests => _l10n.insuranceRequests;
  String get claimRequests => _l10n.claimRequests;
  String get newInsuranceRequest => _l10n.newInsuranceRequest;
  String get newClaimRequest => _l10n.newClaimRequest;
  String get noInsuranceRequests => _l10n.noInsuranceRequests;
  String get claimRequest => _l10n.claimRequest;
  String get quoteRequest => _l10n.quoteRequest;

  // Status labels
  String get statusPending => _l10n.statusPending;
  String get statusAccepted => _l10n.statusAccepted;
  String get statusRejected => _l10n.statusRejected;
  String get statusReceived => _l10n.statusReceived;
  String get statusInsurancePending => _l10n.statusInsurancePending;

  // Claim stages
  String get stageReceived => _l10n.stageReceived;
  String get stageExpertAssigned => _l10n.stageExpertAssigned;
  String get stageRepairAuthorised => _l10n.stageRepairAuthorised;
}
