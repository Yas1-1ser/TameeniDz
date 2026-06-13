import 'package:intl/intl.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/services/admin_service.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';

class ClaimsManagementScreen extends ConsumerStatefulWidget {
  const ClaimsManagementScreen({super.key});

  @override
  ConsumerState<ClaimsManagementScreen> createState() =>
      _ClaimsManagementScreenState();
}

class _ClaimsManagementScreenState extends ConsumerState<ClaimsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(context, l10n.adminClaims),
      bottomNavigationBar: adminBottomNav(context, 0, l10n),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _adminService.fetchClaims(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
            );
          }
          final allClaims = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                color: context.colors.surface,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFC9A96E),
                  labelColor: const Color(0xFF2D1F0E),
                  unselectedLabelColor: const Color(0xFF8B7355),
                  labelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(text: l10n.all),
                    Tab(text: l10n.statusPending),
                    Tab(text: l10n.statusAccepted),
                    Tab(text: l10n.statusRejected),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildClaimsList(allClaims),
                    _buildClaimsList(
                      allClaims.where((c) => c['status'] == 'pending').toList(),
                    ),
                    _buildClaimsList(
                      allClaims
                          .where((c) => c['status'] == 'approved')
                          .toList(),
                    ),
                    _buildClaimsList(
                      allClaims
                          .where((c) => c['status'] == 'rejected')
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClaimsList(List<Map<String, dynamic>> claims) {
    final l10n = AppLocalizations.of(context)!;
    if (claims.isEmpty) {
      return Center(
        child: Text(
          l10n.noRequestsFound,
          style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF8B7355)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: claims.length,
      itemBuilder: (context, index) {
        final claim = claims[index];
        final double amount =
            (claim['estimated_amount'] as num?)?.toDouble() ?? 0.0;

        return StaggeredListItem(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DDD0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      claim['subscriber_name'] ?? 'Client',
                      style: const TextStyle(
                        color: Color(0xFF2D1F0E),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      _formatDZD(amount),
                      style: const TextStyle(
                        color: Color(0xFFC9A96E),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  claim['description'] ?? 'No description provided.',
                  style: const TextStyle(
                    color: Color(0xFF8B7355),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (claim['status'] == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SpringButton(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFA03030),
                              side: const BorderSide(color: Color(0xFFA03030)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              l10n.reject,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SpringButton(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A96E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: Text(
                              l10n.accept,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDZD(double val) {
    return '${NumberFormat('#,###', 'ar').format(val.round())} دج';
  }
}
