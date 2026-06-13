import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/utils/number_utils.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import '../widgets/dashboard_chart.dart';
import 'package:tameenidz/core/services/admin_service.dart';

class AdminSalesScreen extends ConsumerStatefulWidget {
  const AdminSalesScreen({super.key});

  @override
  ConsumerState<AdminSalesScreen> createState() => _AdminSalesScreenState();
}

class _AdminSalesScreenState extends ConsumerState<AdminSalesScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(context, l10n.salesTabTitle),
      bottomNavigationBar: adminBottomNav(context, 0, l10n),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _adminService.fetchAllSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
            );
          }
          final sales = snapshot.data ?? [];
          final totalRevenue = sales.fold(
            0.0,
            (sum, item) =>
                sum + ((item['total_amount'] as num?)?.toDouble() ?? 0.0),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsOverview(totalRevenue, sales.length, l10n),
                const SizedBox(height: 24),
                Text(
                  l10n.performanceOverview,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1F0E),
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _adminService.fetchChartData(),
                  builder: (context, chartSnapshot) {
                    if (chartSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5DDD0),
                            width: 0.5,
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC9A96E),
                          ),
                        ),
                      );
                    }
                    return AdminDashboardChart(data: chartSnapshot.data ?? []);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.salesList,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1F0E),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return StaggeredListItem(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildSaleTile(sale, l10n),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsOverview(double revenue, int count, AppLocalizations l10n) {
    return Row(
      children: [
        _statItem(
          l10n.totalRevenue,
          _formatDZD(revenue),
          Icons.payments_outlined,
          const Color(0xFFC9A96E),
        ),
        const SizedBox(width: 12),
        _statItem(
          l10n.salesTabTitle,
          count.toString(),
          Icons.shopping_cart_outlined,
          const Color(0xFF2D1F0E),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1F0E),
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF8B7355),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleTile(Map<String, dynamic> sale, AppLocalizations l10n) {
    final double amount = (sale['total_amount'] as num?)?.toDouble() ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xFFC9A96E),
            size: 20,
          ),
        ),
        title: Text(
          sale['client_name'] ?? l10n.client,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1F0E),
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: Text(
          sale['policy_type'] ?? l10n.insurancePlan,
          style: const TextStyle(
            color: Color(0xFF8B7355),
            fontSize: 11,
            fontFamily: 'Cairo',
          ),
        ),
        trailing: Text(
          _formatDZD(amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1F0E),
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  String _formatDZD(double val) {
    return '${safeNumberFormat(context, pattern: '#,###').format(val.round())} ${AppLocalizations.of(context)!.dzd}';
  }
}
