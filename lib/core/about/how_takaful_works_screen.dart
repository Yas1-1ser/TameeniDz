import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/about/takaful_step_card.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class HowTakafulWorksScreen extends StatelessWidget {
  const HowTakafulWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.beigeBg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 190,
              backgroundColor: AppColors.primaryGreen,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF154729), AppColors.primaryGreen],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const SizedBox(height: 10),
                      const Icon(Icons.groups_rounded, color: Colors.white, size: 38)
                          .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 10),
                      Text(l10n.howTakafulWorks,
                          style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                          .animate().fadeIn(duration: 400.ms, delay: 150.ms),
                      Text('فهم مبادئ التأمين التكافلي الإسلامي',
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: Colors.white70))
                          .animate().fadeIn(duration: 400.ms, delay: 280.ms),
                    ]),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Concept intro
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.beigeCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.warmDivider),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.takafulConcept,
                          style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                      const SizedBox(height: 10),
                      Text(l10n.takafulDescription,
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, height: 1.7, color: colors.slate500)),
                    ]),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 24),

                  Text(l10n.theProcess,
                      style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen))
                      .animate(delay: 100.ms).fadeIn().slideX(begin: -0.08, end: 0),
                  const SizedBox(height: 16),

                  ...[
                    (l10n.stepContribution,    l10n.stepContributionDesc, Icons.account_balance_wallet_outlined),
                    (l10n.stepPooling,          l10n.stepPoolingDesc,      Icons.groups_outlined),
                    (l10n.stepProtection,       l10n.stepProtectionDesc,   Icons.shield_outlined),
                    (l10n.stepSurplus,          l10n.stepSurplusDesc,      Icons.savings_outlined),
                  ].asMap().entries.map((e) => TakafulStepCard(
                    index: e.key + 1,
                    title: e.value.$1,
                    description: e.value.$2,
                    icon: e.value.$3,
                    delayMs: 200 + e.key * 100,
                  )),

                  const SizedBox(height: 24),

                  // Comparison table
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.beigeCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.warmDivider),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(children: [
                      Text(l10n.takafulVsConventional,
                          style: GoogleFonts.amiri(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                      const SizedBox(height: 8),
                      // Header
                      Row(children: [
                        Expanded(flex: 3, child: _TableHeader('تقليدي',    const Color(0xFFA03030))),
                        Expanded(flex: 3, child: _TableHeader('تكافلي',    AppColors.primaryGreen)),
                        Expanded(flex: 2, child: _TableHeader('المعيار',   AppColors.goldAccent)),
                      ]),
                      const Divider(height: 20),
                      _CompRow(l10n.basis,     l10n.mutualCooperation, l10n.commercialProfit),
                      const Divider(height: 16),
                      _CompRow(l10n.ownership, l10n.policyholders,      l10n.shareholders),
                      const Divider(height: 16),
                      _CompRow(l10n.surplus,   l10n.distributed,        l10n.retained),
                    ]),
                  ).animate(delay: 700.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: AppFooter()),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final Color color;
  const _TableHeader(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.bold, color: color),
      textAlign: TextAlign.center);
}

class _CompRow extends StatelessWidget {
  final String label, takaful, conv;
  const _CompRow(this.label, this.takaful, this.conv);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 3, child: Text(conv,    style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: const Color(0xFFA03030), fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
      Expanded(flex: 3, child: Text(takaful, style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
      Expanded(flex: 2, child: Text(label,   style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: context.colors.slate500, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
    ]);
  }
}
