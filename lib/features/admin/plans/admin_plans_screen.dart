import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import '../../shared/data/plan_repository.dart';

class AdminPlansScreen extends ConsumerWidget {
  const AdminPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final plansAsync = ref.watch(plansStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(context, l10n.plansManagement),
      bottomNavigationBar: adminBottomNav(context, 0, l10n),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.availablePlans,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1F0E), fontFamily: 'Cairo'),
                ),
                // Add button removed for Admin (View Only)
              ],
            ),
            const SizedBox(height: 16),
            plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(l10n.noPlansFound, style: const TextStyle(fontFamily: 'Cairo')),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, i) {
                    final plan = plans[i];
                    return StaggeredListItem(
                      delay: Duration(milliseconds: i * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F0E8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                plan.iconType == 'workspace_premium' ? Icons.workspace_premium : Icons.shield_outlined,
                                color: const Color(0xFFC9A96E), 
                                size: 24
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.companyName,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B7355), fontFamily: 'Cairo'),
                                  ),
                                  Text(
                                    plan.coverage,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D1F0E), fontFamily: 'Cairo'),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l10n.startingFrom} ${plan.premium} ${l10n.dzd}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC9A96E), fontFamily: 'Cairo'),
                                  ),
                                ],
                              ),
                            ),
                            // Edit button removed for Admin (View Only)
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
