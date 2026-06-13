import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF154729), AppColors.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 38,
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.aboutUs,
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                      Text(
                        'تأميني إيليت — ريادة التأمين التكافلي',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 320.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InfoCard(
                  delay: 0,
                  icon: Icons.auto_stories_rounded,
                  title: 'قصتنا',
                  body:
                      'تأسست تأميني إيليت لتكون المنصة الرقمية الأولى للتأمين التكافلي في الجزائر. انطلقنا من قناعة راسخة بأن المسلم الجزائري يستحق تأميناً يحترم قيمه الإسلامية دون التنازل عن الجودة والحداثة.',
                  colors: colors,
                ),

                _InfoCard(
                  delay: 80,
                  icon: Icons.visibility_rounded,
                  title: 'رؤيتنا',
                  body:
                      'أن نكون المرجع الأول للتأمين التكافلي الرقمي في شمال أفريقيا، بمنتجات مبتكرة تجمع بين الأصالة الإسلامية والتكنولوجيا الحديثة.',
                  colors: colors,
                ),

                _InfoCard(
                  delay: 160,
                  icon: Icons.flag_rounded,
                  title: 'مهمتنا',
                  body:
                      'توفير حلول تأمينية شرعية وميسرة لكل جزائري، من خلال منصة رقمية شاملة تضمن الشفافية والعدالة وسرعة الخدمة.',
                  colors: colors,
                ),

                const SizedBox(height: 12),

                Text(
                  'قيمنا',
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryTint,
                  ),
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.08, end: 0),
                const SizedBox(height: 14),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: const [
                    _ValueTile(
                      icon: Icons.balance_rounded,
                      label: 'الشريعة الإسلامية',
                      delay: 240,
                    ),
                    _ValueTile(
                      icon: Icons.handshake_rounded,
                      label: 'التضامن والتكافل',
                      delay: 300,
                    ),
                    _ValueTile(
                      icon: Icons.visibility_rounded,
                      label: 'الشفافية الكاملة',
                      delay: 360,
                    ),
                    _ValueTile(
                      icon: Icons.rocket_launch_rounded,
                      label: 'الابتكار الرقمي',
                      delay: 420,
                    ),
                  ],
                ).animate(delay: 230.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 20),

                Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.09),
                            AppColors.primaryGreen.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _StatPill(value: '+5000', label: 'عميل مسجّل'),
                          _StatPill(value: '2', label: 'شركة تكافل'),
                          _StatPill(value: '48h', label: 'معالجة المطالبات'),
                        ],
                      ),
                    )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.08, end: 0),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final int delay;
  final IconData icon;
  final String title, body;
  final AppColorsExtension colors;
  const _InfoCard({
    required this.delay,
    required this.icon,
    required this.title,
    required this.body,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.beigeCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.warmDivider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryTint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  color: colors.slate500,
                  height: 1.7,
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int delay;
  const _ValueTile({
    required this.icon,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
          decoration: BoxDecoration(
            color: colors.beigeCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.goldAccent, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryTint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 11,
            color: context.colors.slate500,
          ),
        ),
      ],
    );
  }
}
