import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';

/// Provider that fetches total wallet balance from all operators
final _walletBalanceProvider = FutureProvider<double>((ref) async {
  final supabase = Supabase.instance.client;
  try {
    final data = await supabase
        .from('users')
        .select('wallet_balance')
        .eq('role', 'operator');
    double total = 0;
    for (final row in data) {
      total += (row['wallet_balance'] as num?)?.toDouble() ?? 0;
    }
    return total;
  } catch (_) {
    return 0;
  }
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final balanceAsync = ref.watch(_walletBalanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(context, l10n.totalWallet),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(context, l10n, balanceAsync),
            const SizedBox(height: 24),
            Text(
              l10n.recentActivity,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1F0E),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityList(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<double> balanceAsync,
  ) {
    final balanceText = balanceAsync.when(
      data:
          (balance) =>
              '${NumberFormat('#,###', 'ar').format(balance.round())} ${l10n.dzd}',
      loading: () => '--- ${l10n.dzd}',
      error: (_, __) => '--- ${l10n.dzd}',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1F0E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D1F0E).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.availableBalance,
            style: const TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            balanceText,
            style: const TextStyle(
              color: Color(0xFFC9A96E),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.accumulatedCommissions,
            style: const TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 40,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.adminWithdraw),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A96E),
                foregroundColor: const Color(0xFF2D1F0E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.withdraw,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context, AppLocalizations l10n) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F0E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Color(0xFFC9A96E),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.commissionsAdmin,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1F0E),
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        '${l10n.insurancePlan} #45821',
                        style: const TextStyle(
                          color: Color(0xFF8B7355),
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+2,500 ${l10n.dzd}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC9A96E),
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
