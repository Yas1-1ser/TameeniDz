import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expanded;
  String _search = '';

  static const _qa = [
    (Icons.help_outline_rounded, 'ما هو التأمين التكافلي؟',
     'نظام تأمين إسلامي يقوم على مبدأ التضامن والتعاون بين المشتركين وفق أحكام الشريعة الإسلامية. يختلف عن التأمين التقليدي بغياب الغرر والربا.'),
    (Icons.person_add_outlined, 'كيف أشترك في خطة التأمين؟',
     "اضغط على 'احصل على عرض سعر'، أدخل بياناتك واختر الخطة المناسبة ثم أكمل الدفع. العملية بأكملها لا تستغرق أكثر من 5 دقائق."),
    (Icons.timer_outlined, 'ما هي مدة معالجة المطالبة؟',
     'تتم معالجة المطالبات خلال 48 ساعة من تقديم الوثائق المطلوبة. يمكنك متابعة حالة مطالبتك مباشرة من التطبيق.'),
    (Icons.cancel_outlined, 'هل يمكنني إلغاء اشتراكي؟',
     'نعم، يمكنك إلغاء اشتراكك في أي وقت مع استرداد الجزء المتبقي من الرصيد وفق شروط العقد المبرم.'),
    (Icons.document_scanner_outlined, 'ما الوثائق المطلوبة للمطالبة؟',
     'تختلف الوثائق حسب نوع التأمين. للسيارات: البطاقة الرمادية، رخصة السياقة، تقرير الحادث. للسكن: وثيقة الملكية والصور.'),
    (Icons.payments_outlined, 'كيف يتم صرف التعويض؟',
     'يُصرف التعويض عبر تحويل بنكي أو شيك بعد الموافقة على المطالبة وتوقيع وثيقة الاستلام.'),
    (Icons.support_agent_rounded, 'كيف أتواصل مع الدعم؟',
     'يمكنك التواصل معنا عبر صفحة اتصل بنا، أو البريد الإلكتروني support@tameenielite.dz، أو الهاتف +213 XX XX XX XX.'),
    (Icons.share_outlined, 'هل يمكنني مشاركة وثيقتي؟',
     'نعم، يمكنك مشاركة وثيقة التأمين الرقمية من قسم وثائقي مباشرة عبر تطبيقات المراسلة أو طباعتها.'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final filtered = _search.isEmpty
        ? _qa
        : _qa.where((q) => q.$2.contains(_search) || q.$3.contains(_search)).toList();

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
                    const SizedBox(height: 8),
                    const Icon(Icons.quiz_outlined, color: Colors.white, size: 36)
                        .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 8),
                    Text(l10n.faq, style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                        .animate().fadeIn(duration: 400.ms, delay: 150.ms),
                    Text('إجابات على أكثر أسئلتكم شيوعاً',
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: Colors.white70))
                        .animate().fadeIn(duration: 400.ms, delay: 280.ms),
                  ]),
                ),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() { _search = v; _expanded = null; }),
                decoration: InputDecoration(
                  hintText: 'ابحث عن سؤال...',
                  hintStyle: GoogleFonts.ibmPlexSansArabic(color: colors.slate500, fontSize: 13),
                  filled: true, fillColor: colors.beigeCard,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.warmDivider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.warmDivider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final isOpen = _expanded == i;
                  return GestureDetector(
                    onTap: () => setState(() => _expanded = isOpen ? null : i),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colors.beigeCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOpen ? AppColors.primaryGreen.withValues(alpha: 0.4) : colors.warmDivider,
                          width: isOpen ? 1.5 : 1,
                        ),
                        boxShadow: isOpen ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))] : [],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(children: [
                            AnimatedRotation(
                              turns: isOpen ? 0.25 : 0,
                              duration: 250.ms,
                              child: Icon(Icons.arrow_forward_ios_rounded, size: 14,
                                  color: isOpen ? AppColors.primaryGreen : colors.slate500),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(filtered[i].$2,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isOpen ? AppColors.primaryGreen : colors.primaryText,
                                  )),
                            ),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (isOpen ? AppColors.primaryGreen : colors.warmDivider).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(filtered[i].$1, size: 16,
                                    color: isOpen ? AppColors.primaryGreen : colors.slate500)),
                          ]),
                        ),
                        if (isOpen)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(filtered[i].$3,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 13, color: colors.slate500, height: 1.7)),
                            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
                          ),
                      ]),
                    ),
                  ).animate(delay: Duration(milliseconds: i * 50))
                      .fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
                },
                childCount: filtered.length,
              ),
            ),
          ),

          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(children: [
                  Icon(Icons.search_off_rounded, size: 56, color: colors.slate300),
                  const SizedBox(height: 12),
                  Text('لا توجد نتائج لـ "$_search"',
                      style: GoogleFonts.ibmPlexSansArabic(color: colors.slate500)),
                ]),
              ),
            ),

          const SliverToBoxAdapter(child: AppFooter()),
        ],
      ),
    );
  }
}
