import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/providers/operator_providers.dart';
import 'package:tameenidz/features/shared/domain/models/surplus_model.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/widgets/email_verification_banner.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AtSurplusScreen extends ConsumerStatefulWidget {
  const AtSurplusScreen({super.key});

  @override
  ConsumerState<AtSurplusScreen> createState() => _AtSurplusScreenState();
}

class _AtSurplusScreenState extends ConsumerState<AtSurplusScreen> {
  int _activeChartType = 0; // 0 = Bar, 1 = Pie

  @override
  Widget build(BuildContext context) {
    final quarterlyAsync = ref.watch(atQuarterlySurplusProvider);
    final l10n = AppLocalizations.of(context)!;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.dashboard, '/at/dashboard'),
      (Icons.account_balance_wallet_rounded, l10n.surplus, '/at/surplus'),
      (Icons.archive_outlined, l10n.policies, '/at/policies'),
      (Icons.receipt_long_outlined, l10n.claims, '/at/claims'),
      (Icons.local_offer_outlined, l10n.manageOffers, '/at/offers'),
      (Icons.settings_outlined, l10n.settings, '/at/settings'),
    ];

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: PortalLayout(
        selectedIndex: 1,
        portalTitle: 'جزائر تكافل',
        portalSubtitle: 'توزيع الفائض',
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
            child: Column(
              children: [
                const EmailVerificationBanner(),
                Expanded(
                  child: quarterlyAsync.when(
                    data: (quarters) => _buildContent(context, quarters, l10n),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: kGoldDeep),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        'خطأ في تحميل البيانات: $err',
                        style: GoogleFonts.ibmPlexSansArabic(color: kStatusRejected),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (idx) {
            if (idx == 0) context.go('/at/dashboard');
            if (idx == 1) context.go('/at/surplus');
            if (idx == 2) context.go('/at/policies');
            if (idx == 3) context.go('/at/settings');
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kGoldDeep,
          unselectedItemColor: kInkMuted,
          backgroundColor: kIvory,
          selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 11),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.dashboard),
            BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_rounded), label: l10n.surplus),
            BottomNavigationBarItem(icon: const Icon(Icons.archive_outlined), label: l10n.policies),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, List<SurplusQuarterModel> quarters, AppLocalizations l10n) {
    final totalSurplus = quarters.fold<double>(
        0, (sum, q) => sum + q.policyholdersFund + q.shareholdersFund);
    final mockBeneficiaries = quarters.length * 485 + 1420;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(l10n, totalSurplus, mockBeneficiaries),
          const SizedBox(height: 24),
          _buildAnalyticsCard(quarters, l10n),
          const SizedBox(height: 24),
          Text(
            'سجل التوزيع الربع سنوي',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuarterlyList(quarters, l10n),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n, double total, int beneficiaries) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: kGoldGradient,
        borderRadius: BorderRadius.circular(kRadiusLg),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي فائض التأمين التعاوني الموزع',
                style: GoogleFonts.ibmPlexSansArabic(
                  color: kIvory.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.stars_rounded, color: kGoldShimmer, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${intl.NumberFormat('#,###').format(total)} د.ج',
            style: GoogleFonts.cormorantGaramond(
              color: kIvory,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kIvory.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(kRadiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded, color: kGoldShimmer, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.beneficiariesCount(intl.NumberFormat('#,###').format(beneficiaries)),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: kIvory,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(List<SurplusQuarterModel> quarters, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: kParchment),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التحليل البياني للفائض',
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kGoldDeep,
                ),
              ),
              Row(
                children: [
                  _chartTypeToggle(0, Icons.bar_chart_rounded),
                  const SizedBox(width: 6),
                  _chartTypeToggle(1, Icons.pie_chart_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _activeChartType == 0
                ? _buildBarChart(quarters)
                : _buildPieChart(quarters),
          ),
          const SizedBox(height: 16),
          // FIXED: Using Wrap to prevent legend overflow
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendItem(l10n.policyholdersSurplusLegend, kGoldDeep),
              _legendItem(l10n.shareholdersManagementFeeLegend, kGoldLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartTypeToggle(int type, IconData icon) {
    final isSelected = _activeChartType == type;
    return GestureDetector(
      onTap: () => setState(() => _activeChartType = type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? kGoldDeep : kParchment.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(kRadiusSm),
        ),
        child: Icon(icon, size: 18, color: isSelected ? kIvory : kInkMuted),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 10,
              color: kInkMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<SurplusQuarterModel> quarters) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: quarters.isEmpty
            ? 1000
            : quarters
                    .map((q) => q.policyholdersFund + q.shareholdersFund)
                    .reduce((a, b) => a > b ? a : b) *
                1.2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= quarters.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    quarters[index].titleAr,
                    style: GoogleFonts.ibmPlexSansArabic(fontSize: 10, color: kInkMuted, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: quarters.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: q.policyholdersFund, color: kGoldDeep, width: 14),
              BarChartRodData(toY: q.shareholdersFund, color: kGoldLight, width: 14),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(List<SurplusQuarterModel> quarters) {
    double totalPolicyholders = 0;
    double totalShareholders = 0;
    for (var q in quarters) {
      totalPolicyholders += q.policyholdersFund;
      totalShareholders += q.shareholdersFund;
    }
    final total = totalPolicyholders + totalShareholders;
    if (total == 0) return const Center(child: Text('لا توجد بيانات للفائض'));

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: kGoldDeep,
            value: totalPolicyholders,
            title: '${((totalPolicyholders / total) * 100).toStringAsFixed(0)}٪',
            radius: 50,
            titleStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.bold, color: kIvory),
          ),
          PieChartSectionData(
            color: kGoldLight,
            value: totalShareholders,
            title: '${((totalShareholders / total) * 100).toStringAsFixed(0)}٪',
            radius: 50,
            titleStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.bold, color: kInk),
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterlyList(List<SurplusQuarterModel> quarters, AppLocalizations l10n) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quarters.length,
      itemBuilder: (context, index) {
        final q = quarters[index];
        final totalQ = q.policyholdersFund + q.shareholdersFund;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: kParchment),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(q.titleAr, style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: kGoldDeep)),
                  Text('${intl.NumberFormat('#,###').format(totalQ)} د.ج', style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w900, color: kGoldDeep)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: kParchment, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _fundRowItem('فائض المشتركين (90٪)', q.policyholdersFund, kGoldDeep),
                  _fundRowItem('حصة شركة الإدارة (10٪)', q.shareholdersFund, kGoldMid),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fundRowItem(String title, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(title, style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: kInkMuted)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Text(
            '${intl.NumberFormat('#,###').format(val)} د.ج',
            style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w800, color: kInk),
          ),
        ),
      ],
    );
  }
}
