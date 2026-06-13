// lib/features/client/home/client_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/providers/service_providers.dart';
import 'package:tameenidz/core/providers/notification_providers.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/features/shared/widgets/email_verification_banner.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/data/plan_repository.dart';
import 'package:tameenidz/features/client/policies/policy_providers.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() =>
      _ClientDashboardScreenState();
}

class _ClientDashboardScreenState
    extends ConsumerState<ClientDashboardScreen> {
  static const int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final userAsync = ref.watch(userProfileProvider);
    final policiesAsync = ref.watch(clientPoliciesStreamProvider);

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.folder_shared_rounded, l10n.myDocuments, AppRoutes.myPolicies),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return PortalLayout(
      selectedIndex: _navIndex,
      menuItems: menuItems,
      portalTitle: l10n.clientPortal,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      body: PageEntryAnimation(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EmailVerificationBanner(),
                    const SizedBox(height: 12),

                    StaggeredListItem(
                      delay: const Duration(milliseconds: 0),
                      child: _buildWelcomeHeader(context, l10n, userAsync),
                    ),

                    const SizedBox(height: 24),

                    StaggeredListItem(
                      delay: const Duration(milliseconds: 80),
                      child: _buildQuickActions(context, l10n),
                    ),

                    const SizedBox(height: 32),
                    
                    // Policy Status Summary (Pending/Accepted) - Context-aware status bar
                    policiesAsync.when(
                      data: (policies) {
                        final urgent = policies.where((p) => 
                          p.status == PolicyStatus.pending || 
                          (p.status == PolicyStatus.accepted && p.paidAt == null)
                        ).toList();
                        
                        if (urgent.isEmpty) return const SizedBox.shrink();
                        
                        return StaggeredListItem(
                          delay: const Duration(milliseconds: 100),
                          child: _buildPolicyStatusSummary(context, urgent.first, l10n),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.insurancePacksAndServices,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryGreen,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Operator Selection Sections - Visual separation of AT and AI
                    StaggeredListItem(
                      delay: const Duration(milliseconds: 120),
                      child: _buildOperatorChoice(
                        context,
                        title: l10n.operatorTakafulTitle,
                        subtitle: l10n.operatorTakafulSubtitle,
                        color: colors.primaryGreen,
                        icon: Icons.account_balance_rounded,
                        logoPath: 'assets/images/logotameen.jpg',
                        onTap: () => context.push(AppRoutes.clientOperatorTakaful),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StaggeredListItem(
                      delay: const Duration(milliseconds: 140),
                      child: _buildOperatorChoice(
                        context,
                        title: l10n.operatorIttihadTitle,
                        subtitle: l10n.operatorIttihadSubtitle,
                        color: colors.alIttihadGreen,
                        icon: Icons.verified_user_rounded,
                        logoPath: 'assets/images/logotameen.jpg',
                        onTap: () => context.push(AppRoutes.clientOperatorIttihad),
                      ),
                    ),

                    const SizedBox(height: 32),

                    StaggeredListItem(
                      delay: const Duration(milliseconds: 160),
                      child: _buildPackagesSection(context, l10n),
                    ),

                    const SizedBox(height: 28),

                    StaggeredListItem(
                      delay: const Duration(milliseconds: 320),
                      child: _buildRoadsidePromo(context, l10n),
                    ),

                    const SizedBox(height: 28),

                    StaggeredListItem(
                      delay: const Duration(milliseconds: 400),
                      child: _buildTakafulDefinition(context, l10n),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar(AppColorsExtension colors, String name) {
    return Container(
      color: colors.primaryGreen.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '؟',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.primaryGreen,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue userAsync,
  ) {
    final colors = context.colors;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return userAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(),
      data: (dbUser) {
        final authUser = Supabase.instance.client.auth.currentUser;
        final name =
            (authUser?.userMetadata?['full_name'] ?? dbUser?['full_name'] ?? l10n.welcomeGuest)
                .split(' ')
                .first;
        final avatarUrl = authUser?.userMetadata?['avatar_url'] as String?;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Profile photo
                GestureDetector(
                  onTap: () => context.push(AppRoutes.profile),
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.only(left: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primaryGreen.withValues(alpha: 0.3), width: 2),
                      boxShadow: [
                        BoxShadow(color: colors.primaryGreen.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: ClipOval(
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultAvatar(colors, name),
                            )
                          : _defaultAvatar(colors, name),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomePrefix,
                      style: TextStyle(
                        fontSize: 15,
                        color: colors.primaryGreen,
                        fontFamily: 'IBMPlexArabic',
                      ),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 26,
                        color: colors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ScheherazadeNew',
                      ),
                    ),
                    Text(
                      l10n.halalTakafulInsurance,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primaryGreen.withValues(alpha: 0.55),
                        fontFamily: 'IBMPlexArabic',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              onPressed: () => context.push(AppRoutes.notifications),
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                backgroundColor: colors.goldAccent,
                child: Icon(
                  Icons.notifications_outlined,
                  color: colors.primaryGreen,
                  size: 26,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOperatorChoice(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    String? logoPath,
  }) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.premiumCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: logoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          logoPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontFamily: 'IBMPlexArabic',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.premiumSubtext,
                      fontFamily: 'IBMPlexArabic',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.3), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyStatusSummary(BuildContext context, PolicyModel policy, AppLocalizations l10n) {
    final colors = context.colors;
    final isAccepted = policy.status == PolicyStatus.accepted;
    final statusColor = isAccepted ? colors.accepted : colors.pending;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isAccepted ? Icons.check_circle_outline_rounded : Icons.pending_actions_rounded,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAccepted ? l10n.requestAcceptedTitle : l10n.requestUnderReview,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
                Text(
                  isAccepted ? l10n.policyReadyForPayment(policy.planName ?? l10n.unspecified) : l10n.notifiedWhenApproved(policy.displayCompanyName),
                  style: TextStyle(fontSize: 11, color: colors.premiumSubtext),
                ),
              ],
            ),
          ),
          if (isAccepted)
            TextButton(
              onPressed: () => context.push('/client/payment/${policy.id}', extra: policy.amount),
              child: Text(
                l10n.payNow,
                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final actions = [
      (Icons.compare_arrows_rounded, l10n.myPlans, colors.primaryGreen,
          AppRoutes.plans),
      (Icons.description_rounded, l10n.myDocuments, colors.alIttihadGreen,
          AppRoutes.myPolicies),
      (Icons.assignment_late_rounded, l10n.myClaims, colors.pending,
          AppRoutes.myClaims),
      (Icons.sos_rounded, l10n.emergency, colors.error,
          AppRoutes.sos),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions.map((item) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: _QuickActionTile(
              icon: item.$1,
              label: item.$2,
              color: item.$3,
              onTap: () => context.push(item.$4),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackagesSection(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final plansAsync = ref.watch(plansStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.protectionPacks,
          subtitle: l10n.modernPacksCompetitivePrices,
          onSeeAll: () => context.push(AppRoutes.plans),
          seeAllText: l10n.seeAll,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 195,
          child: plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noPlansAvailable,
                    style: TextStyle(color: colors.premiumSubtext, fontFamily: 'Cairo'),
                  ),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _PackageCard(
                    arabicName: plan.companyName,
                    frenchName: plan.companyEn,
                    description: plan.categoryAr.isNotEmpty ? plan.categoryAr : plan.coverage,
                    priceLabel: l10n.fromPrice(plan.priceNoteAr.isNotEmpty
                        ? plan.priceNoteAr
                        : '${plan.premium} ${l10n.dzd}'),
                    icon: plan.resolvedIcon,
                    color: plan.operatorColor,
                    onTap: () => context.push(AppRoutes.quoteForm, extra: plan),
                  );
                },
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: colors.primaryGreen),
            ),
            error: (err, _) => Center(
              child: Text('${l10n.unexpectedError}: $err', style: TextStyle(color: colors.error)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadsidePromo(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgCol = isDark ? colors.error.withValues(alpha: 0.15) : colors.error.withValues(alpha: 0.05);
    final borderCol = colors.error.withValues(alpha: 0.2);
    final iconBgCol = colors.error.withValues(alpha: 0.1);
    final textCol = isDark ? colors.error.withValues(alpha: 0.8) : colors.error;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.sos),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBgCol,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sos_rounded,
                color: textCol,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.roadsideServices,
                    style: TextStyle(
                      fontFamily: 'IBMPlexArabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textCol,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    l10n.roadsideSubtitle,
                    style: TextStyle(
                      fontFamily: 'IBMPlexArabic',
                      fontSize: 12,
                      color: textCol.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textCol.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakafulDefinition(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.goldAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🕌', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.takafulTitle,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.takafulDescription,
            style: TextStyle(
              fontFamily: 'IBMPlexArabic',
              fontSize: 13,
              color: colors.primaryGreen.withValues(alpha: 0.75),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.push(AppRoutes.howTakafulWorks),
            child: Text(
              l10n.howTakafulWorksAction,
              style: TextStyle(
                fontFamily: 'IBMPlexArabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: colors.goldAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String seeAllText;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.seeAllText,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'IBMPlexArabic',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.primaryGreen,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'IBMPlexArabic',
                fontSize: 12,
                color: colors.primaryGreen.withValues(alpha: 0.55),
              ),
            ),
          ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              seeAllText,
              style: TextStyle(
                fontFamily: 'IBMPlexArabic',
                fontSize: 13,
                color: colors.goldAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexArabic',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String arabicName;
  final String frenchName;
  final String description;
  final String priceLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PackageCard({
    required this.arabicName,
    required this.frenchName,
    required this.description,
    required this.priceLabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.premiumCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              arabicName,
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              frenchName,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.60),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'IBMPlexArabic',
                fontSize: 10,
                color: colors.primaryGreen.withValues(alpha: 0.65),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              priceLabel,
              style: TextStyle(
                fontFamily: 'IBMPlexArabic',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
