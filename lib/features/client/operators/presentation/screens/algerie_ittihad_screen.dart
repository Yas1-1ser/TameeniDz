// lib/features/client/operators/presentation/screens/algerie_ittihad_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/operator_header.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/data/plan_repository.dart';
import 'package:tameenidz/core/utils/responsive.dart';
import 'package:tameenidz/features/shared/domain/models/plan_model.dart';
import 'package:tameenidz/core/providers/notification_providers.dart';

class AlgerieIttihadScreen extends ConsumerWidget {
  const AlgerieIttihadScreen({super.key});

  static const _operatorId = 'al_ittihad';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    final plansAsync = ref.watch(plansByOperatorProvider(_operatorId));
    final colors = context.colors;
    final themeColor = colors.alIttihadGreen;
    final goldColor = colors.premiumGold;
    final bgColor = colors.beigeBg;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 1000,
          slivers: [
            // ── AppBar ────────────────────────────────────────────────
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: bgColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: goldColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.alIttihadTakaful.split(' - ').first,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        fontSize: Responsive.sp(17),
                      ),
                    ),
                  ],
                ),
              ),
              leading: Center(
                child: IconButton(
                  icon: _circleIcon(context, Icons.chevron_right_rounded, themeColor),
                  onPressed: () => context.pop(),
                ),
              ),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final unreadCount = ref.watch(unreadNotificationsCountProvider);
                    return Center(
                      child: IconButton(
                        icon: Badge(
                          isLabelVisible: unreadCount > 0,
                          backgroundColor: const Color(0xFFE53935),
                          label: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 9)),
                          child: _circleIcon(
                            context,
                            Icons.notifications_none_rounded,
                            themeColor,
                          ),
                        ),
                        onPressed: () => context.push(AppRoutes.notifications),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── Operator Header (no Sharia banner for conventional) ──
            SliverToBoxAdapter(
              child: OperatorHeader(
                name: AppLocalizations.of(context)!.aiCompanyTitle,
                tagline: AppLocalizations.of(context)!.aiPhilosophyTitle,
                themeColor: themeColor,
                badgeText: AppLocalizations.of(context)!.atLicensed,
                isIslamic: false,
                logoPath: 'assets/images/logotameen.jpg',
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(24))),

            // ── Stats ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: const _StatsRow()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              ),
            ),

            // ══════════════════════════════════════════════════════════
            // SECTION 1: من نحن (Who We Are)
            // ══════════════════════════════════════════════════════════
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(32))),
            SliverToBoxAdapter(child: _SectionTitle(title: AppLocalizations.of(context)!.whoWeAreTitle)),
            const SliverToBoxAdapter(child: _WhoWeAreCard()),

            // ── Philosophy (conventional) ─────────────────────────────
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(20))),
            SliverToBoxAdapter(child: _SectionTitle(title: AppLocalizations.of(context)!.aiPhilosophyTitle)),
            const SliverToBoxAdapter(child: _AiPhilosophyCard()),

            // ══════════════════════════════════════════════════════════
            // SECTION 2: خدماتنا التأمينية (Our Services)
            // ══════════════════════════════════════════════════════════
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(32))),
            SliverToBoxAdapter(child: _SectionTitle(title: AppLocalizations.of(context)!.servicesTitle)),
            const SliverToBoxAdapter(child: _ServicesGrid()),

            // ══════════════════════════════════════════════════════════
            // SECTION 3: باقات الحماية (Plans – vertical list)
            // ══════════════════════════════════════════════════════════
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(32))),
            SliverToBoxAdapter(child: _SectionTitle(title: AppLocalizations.of(context)!.protectionPlansIttihadTitle)),

            plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return const SliverToBoxAdapter(child: _EmptyPlans());
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => RepaintBoundary(
                        child: _PlanListCard(plan: plans[index], index: index)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 80 + (index * 60)))
                            .slideY(begin: 0.06, end: 0),
                      ),
                      childCount: plans.length,
                    ),
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: themeColor)),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Documents Guide ───────────────────────────────────────
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(32))),
            SliverToBoxAdapter(child: _SectionTitle(title: AppLocalizations.of(context)!.docsGuideTitle)),
            const SliverToBoxAdapter(child: _DocumentsGuide()),

            // ── Legal Framework ───────────────────────────────────────
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(32))),
            SliverToBoxAdapter(child: _SectionTitle(title: AppLocalizations.of(context)!.legalFrameworkIttihadTitle)),
            const SliverToBoxAdapter(child: _LegalFrameworkCard()),

            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(140))),
          ],
        ),
        bottomNavigationBar: _BottomCta(),
      ),
    );
  }

  Widget _circleIcon(BuildContext context, IconData icon, Color color) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.colors.premiumCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: context.colors.warmDivider.withValues(alpha: 0.15)),
        ),
        child: Center(child: Icon(icon, color: color, size: 22)),
      );
}

// ── Who We Are Card ──────────────────────────────────────────────────────────
class _WhoWeAreCard extends StatelessWidget {
  const _WhoWeAreCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeColor = colors.alIttihadGreen;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.premiumCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.premiumBorder),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.corporate_fare_rounded, color: themeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.aiCompanyTitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.aiCompanyDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: colors.primaryText,
                height: 1.75,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoBadge(icon: Icons.location_on_outlined, label: AppLocalizations.of(context)!.atLocation, color: themeColor),
                const SizedBox(width: 10),
                _InfoBadge(icon: Icons.shield_outlined, label: AppLocalizations.of(context)!.atLicensed, color: colors.premiumGold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoBadge({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Services Grid ────────────────────────────────────────────────────────────
class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeColor = colors.alIttihadGreen;
    final l10n = AppLocalizations.of(context)!;
    final services = [
      (Icons.directions_car_rounded, l10n.serviceCarTitle, l10n.serviceCarDesc),
      (Icons.gavel_rounded, l10n.serviceCivilTitle, l10n.serviceCivilDesc),
      (Icons.home_work_rounded, l10n.servicePropertyTitle, l10n.servicePropertyDesc),
      (Icons.business_center_rounded, l10n.serviceEnterpriseTitle, l10n.serviceEnterpriseDesc),
      (Icons.local_shipping_rounded, l10n.serviceCargoTitle, l10n.serviceCargoDesc),
      (Icons.agriculture_rounded, l10n.serviceAgriRiskTitle, l10n.serviceAgriRiskDesc),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: services.map((s) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.premiumCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.premiumBorder),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.$1, color: themeColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(s.$2,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Text(s.$3,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: colors.premiumGold,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  )),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

// ── Plan List Card (vertical list replacing carousel) ────────────────────────
class _PlanListCard extends StatelessWidget {
  final PlanModel plan;
  final int index;
  const _PlanListCard({required this.plan, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeColor = colors.alIttihadGreen;
    final goldColor = colors.premiumGold;
    final isFeatured = plan.isBestValue;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.quoteForm, extra: plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isFeatured ? themeColor : colors.premiumCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFeatured ? themeColor : colors.premiumBorder,
            width: isFeatured ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isFeatured ? themeColor : Colors.black).withValues(alpha: isFeatured ? 0.18 : 0.05),
              blurRadius: isFeatured ? 18 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isFeatured
                      ? Colors.white.withValues(alpha: 0.15)
                      : themeColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  plan.resolvedIcon,
                  color: isFeatured ? Colors.white : themeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.companyName,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isFeatured ? Colors.white : colors.primaryText,
                            ),
                          ),
                        ),
                        if (isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: goldColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.bestValue,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (plan.coverage.isNotEmpty)
                      Text(
                        plan.coverage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: isFeatured
                              ? Colors.white.withValues(alpha: 0.75)
                              : colors.premiumSubtext,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.startingFrom,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: isFeatured
                                ? Colors.white.withValues(alpha: 0.75)
                                : colors.premiumSubtext,
                          ),
                        ),
                        Text(
                          '${plan.premium} ${AppLocalizations.of(context)!.dzd}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isFeatured ? goldColor : AppColors.goldDeep,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isFeatured
                      ? Colors.white.withValues(alpha: 0.15)
                      : themeColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: isFeatured ? Colors.white : themeColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Philosophy Card (conventional) ───────────────────────────────────────────
class _AiPhilosophyCard extends StatelessWidget {
  const _AiPhilosophyCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.premiumCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.premiumBorder),
        ),
        child: Text(
          AppLocalizations.of(context)!.aiPhilosophyDesc,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: colors.primaryText, height: 1.65),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(Responsive.hPad, 0, Responsive.hPad, Responsive.h(16)),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.premiumGold, AppColors.goldDeep],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.alIttihadGreen,
              )),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.premiumCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.premiumBorder),
          boxShadow: [
            BoxShadow(
              color: colors.premiumGold.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: '+25', label: AppLocalizations.of(context)!.statsExp),
            _StatItem(value: '+150K', label: AppLocalizations.of(context)!.statsClients),
            _StatItem(value: '95%', label: AppLocalizations.of(context)!.statsSatisfaction),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: context.colors.alIttihadGreen)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: context.colors.premiumSubtext, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _DocumentsGuide extends StatelessWidget {
  const _DocumentsGuide();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.premiumCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.premiumBorder),
        ),
        child: Column(children: [
          _docItem(context, AppLocalizations.of(context)!.docCars, AppLocalizations.of(context)!.docCarsDesc),
          Divider(height: 24, color: colors.premiumBorder),
          _docItem(context, AppLocalizations.of(context)!.docCompanies, AppLocalizations.of(context)!.docCompaniesDesc),
          Divider(height: 24, color: colors.premiumBorder),
          _docItem(context, AppLocalizations.of(context)!.docTravelers, AppLocalizations.of(context)!.docTravelersDesc),
        ]),
      ),
    );
  }

  Widget _docItem(BuildContext context, String title, String docs) => Row(children: [
        Icon(Icons.file_present_rounded, color: context.colors.premiumGold, size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: context.colors.premiumText)),
          Text(docs, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: context.colors.premiumSubtext)),
        ]),
      ]);
}

class _LegalFrameworkCard extends StatelessWidget {
  const _LegalFrameworkCard();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colors.premiumHeroBg, colors.premiumHeroEnd]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.premiumHeroBg.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.legalFrameworkIttihadTitle,
              style: TextStyle(fontFamily: 'Cairo', color: colors.premiumGold, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.aiLegalDesc,
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 12, height: 1.6),
          ),
        ]),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta();

  Widget _buildButton(
    BuildContext context, 
    AppColorsExtension colors, 
    Color themeColor,
    String label, 
    IconData icon,
    VoidCallback onTap,
    {bool isPrimary = false}
  ) {
    return SpringButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isPrimary ? LinearGradient(colors: [themeColor, const Color(0xFF0A3D28)]) : null,
          color: isPrimary ? null : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: themeColor.withValues(alpha: 0.3)),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ] : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : themeColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontFamily: 'Cairo', color: isPrimary ? Colors.white : themeColor, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeColor = colors.alIttihadGreen;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(Responsive.hPad, 16, Responsive.hPad, 32),
      decoration: BoxDecoration(
        color: colors.premiumCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context,
            colors,
            themeColor,
            l10n.requestQuote,
            Icons.request_quote_rounded,
            () => context.push(AppRoutes.quoteForm, extra: 'al_ittihad'),
          ),
          const SizedBox(height: 12),
          _buildButton(
            context,
            colors,
            themeColor,
            l10n.requestInsurance,
            Icons.security_rounded,
            () => context.push(AppRoutes.insuranceRequest, extra: 'al_ittihad'),
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _buildButton(
            context,
            colors,
            themeColor,
            l10n.requestClaim,
            Icons.assignment_turned_in_rounded,
            () => context.push(AppRoutes.claimRequest),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans();
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.noData, style: TextStyle(fontFamily: 'Cairo', color: context.colors.premiumSubtext)));
  }
}
