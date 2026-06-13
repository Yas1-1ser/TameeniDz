import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/services/agent_service.dart';
import 'package:tameenidz/features/shared/domain/models/agent_model.dart';
import 'package:tameenidz/features/shared/domain/models/sale_model.dart';
import '../widgets/commission_wallet_card.dart';
import '../widgets/sale_row_card.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  final AgentService _agentService = AgentService();

  @override
  Widget build(BuildContext context) {
    Color bgBeige = context.colors.beigeBg;
    const Color accentGold = Color(0xFFC9A84C);
    const Color darkGreen = Color(0xFF1A3A2A);
    const Color cardWhite = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: bgBeige,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.agentDashboard,
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: accentGold), onPressed: () {}),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: darkGreen),
          onPressed: () {},
        ),
      ),
      body: PageEntryAnimation(child: FutureBuilder<AgentModel>(
        future: _agentService.fetchAgentProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentGold));
          }
          if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context)!.errorLoadingData));
          }
          final agent = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATS ROW
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildStatCard(Icons.shopping_bag_outlined, agent.totalSalesCount.toString(), AppLocalizations.of(context)!.totalSales, accentGold),
                      const SizedBox(width: 14),
                      _buildStatCard(Icons.percent_outlined, '${agent.commissionRate}%', AppLocalizations.of(context)!.myCommissionRate, accentGold),
                      const SizedBox(width: 14),
                      _buildStatCard(Icons.people_outline, AppLocalizations.of(context)!.active, AppLocalizations.of(context)!.accountStatus, Colors.green),
                    ],
                  ),
                ).animate().fadeIn().slideX(),

                const SizedBox(height: 24),

                // WALLET CARD
                CommissionWalletCard(agent: agent).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                // QUICK ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(Icons.person_add_outlined, AppLocalizations.of(context)!.addNewCustomer, () {
                        context.push('/client/quote-form');
                      }, cardWhite, accentGold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(Icons.share_outlined, AppLocalizations.of(context)!.shareMyLink, () {
                        SharePlus.instance.share(ShareParams(text: '${AppLocalizations.of(context)!.shareLinkMessage} tameeni.dz/ref/${agent.id}'));
                      }, cardWhite, accentGold),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),

                // RECENT SALES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recentSales,
                      style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SpringButton(child: TextButton(
                      onPressed: () {},
                      child: Text(AppLocalizations.of(context)!.viewAll, style: const TextStyle(color: accentGold)),
                    )),
                  ],
                ),
                
                const SizedBox(height: 12),

                FutureBuilder<List<SaleModel>>(
                  future: _agentService.fetchMySales(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: accentGold));
                    }
                    final sales = snapshot.data ?? [];
                    if (sales.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)!.noSalesCurrently));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sales.length,
                      itemBuilder: (context, index) => StaggeredListItem(delay: Duration(milliseconds: index * 100), child: SaleRowCard(sale: sales[index])),
                    );
                  },
                ),
              ],
            ),
          );
        },
      )),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color accentColor) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap, Color cardWhite, Color accentGold) {
    return SpringButton(child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3DC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentGold),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ));
  }
}
