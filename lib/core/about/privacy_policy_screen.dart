import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (Icons.info_outline_rounded,      'مقدمة',
     'نحن في تأميني إيليت نلتزم بحماية خصوصيتك وضمان أمان بياناتك الشخصية. توضح هذه السياسة كيفية جمعنا واستخدامنا وحماية معلوماتك.'),
    (Icons.storage_rounded,           'البيانات التي نجمعها',
     'نقوم بجمع المعلومات الضرورية لتقديم خدمات التأمين، بما في ذلك الاسم ورقم الهاتف والبريد الإلكتروني وتفاصيل المركبة أو السكن المؤمن عليه.'),
    (Icons.manage_search_rounded,     'استخدام البيانات',
     'تستخدم بياناتك حصرياً لمعالجة طلبات التأمين وتقديم الدعم الفني وتحسين تجربة المستخدم وضمان الامتثال للقوانين المعمول بها.'),
    (Icons.lock_rounded,              'حماية البيانات',
     'نستخدم تقنيات تشفير متطورة ومعايير أمنية صارمة لمنع الوصول غير المصرح به إلى معلوماتك الشخصية أو الكشف عنها.'),
    (Icons.share_rounded,             'مشاركة البيانات',
     'لا نبيع أو نؤجر بياناتك لأطراف ثالثة. قد نشارك معلوماتك مع شركاء التأمين المرخصين حصراً لمعالجة طلباتك.'),
    (Icons.person_rounded,            'حقوقك',
     'يحق لك الاطلاع على بياناتك وتصحيحها وطلب حذفها في أي وقت. تواصل معنا عبر صفحة الدعم لممارسة هذه الحقوق.'),
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
                    const Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 36)
                        .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 8),
                    Text(l10n.privacyPolicy,
                        style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                        .animate().fadeIn(duration: 400.ms, delay: 150.ms),
                  ]),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('آخر تحديث: يناير 2026',
                  textDirection: ui.TextDirection.rtl,
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: colors.slate500))
                  .animate().fadeIn(duration: 300.ms),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _PolicySection(
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

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final int delay;
  final AppColorsExtension colors;
  const _PolicySection({required this.icon, required this.title, required this.body, required this.delay, required this.colors});

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
          Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primaryGreen, size: 18)),
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
