import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    (Icons.check_circle_outline_rounded, 'القبول بالشروط',
     'باستخدامك لتطبيق تأميني إيليت، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يرجى عدم استخدام التطبيق.'),
    (Icons.miscellaneous_services_rounded, 'الخدمات المقدمة',
     'يوفر تأميني إيليت منصة رقمية لتسهيل الوصول إلى خدمات التأمين التكافلي الإسلامي في الجزائر. نعمل كوسيط بين المؤمن عليهم وشركات التأمين المرخصة.'),
    (Icons.person_pin_rounded, 'التزامات المستخدم',
     'يلتزم المستخدم بتقديم معلومات صحيحة ودقيقة عند التسجيل وتقديم طلبات التأمين. أي معلومات مضللة قد تؤدي إلى إلغاء وثيقة التأمين.'),
    (Icons.gavel_rounded, 'حدود المسؤولية',
     'لا تتحمل تأميني إيليت المسؤولية عن أي أضرار مباشرة أو غير مباشرة ناجمة عن استخدام التطبيق. تخضع عمليات التعويض لشروط وثيقة التأمين المبرمة.'),
    (Icons.block_rounded, 'الاستخدام المحظور',
     'يُحظر استخدام المنصة لأي غرض غير مشروع أو مخالف للشريعة الإسلامية، بما في ذلك تقديم بيانات مزوّرة أو محاولة اختراق الأنظمة.'),
    (Icons.update_rounded, 'تعديل الشروط',
     'نحتفظ بحق تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية عبر البريد الإلكتروني أو الإشعارات داخل التطبيق.'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
                    const SizedBox(height: 12),
                    const Icon(Icons.article_outlined, color: Colors.white, size: 36)
                        .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 8),
                    Text(l10n.termsAndConditions,
                        style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))
                        .animate().fadeIn(duration: 400.ms, delay: 150.ms),
                  ]),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('سارية المفعول منذ: يناير 2026',
                  textDirection: ui.TextDirection.rtl,
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: colors.slate500))
                  .animate().fadeIn(duration: 300.ms),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _TermsSection(
                  index: i + 1,
                  icon: _sections[i].$1,
                  title: _sections[i].$2,
                  body: _sections[i].$3,
                  delay: i * 70,
                  colors: colors,
                ),
                childCount: _sections.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: AppFooter()),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final int index, delay;
  final IconData icon;
  final String title, body;
  final AppColorsExtension colors;
  const _TermsSection({required this.index, required this.icon, required this.title, required this.body, required this.delay, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.warmDivider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(title, style: GoogleFonts.amiri(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          const SizedBox(width: 10),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(child: Text('$index',
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen))),
          ),
        ]),
        const SizedBox(height: 10),
        Text(body,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, color: colors.slate500, height: 1.7)),
      ]),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}
