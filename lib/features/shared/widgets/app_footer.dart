// lib/features/shared/widgets/app_footer.dart
// FIXED: Beige theme + correct routes + missing screens (FAQ, Contact, How Takaful Works)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 768;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.beigeBg,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // ── TOP SECTION ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : sw * 0.08,
              vertical: 40,
            ),
            child: isMobile
                ? _buildMobileTop(context, l10n)
                : _buildDesktopTop(context, l10n, sw),
          ),

          // ── DIVIDER ─────────────────────────────────────────────
          Divider(
            color: AppColors.primaryGreen.withValues(alpha: 0.10),
            thickness: 1,
            indent: 24,
            endIndent: 24,
          ),

          // ── BOTTOM BAR ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : sw * 0.08,
              vertical: 20,
            ),
            child: Column(
              children: [
                // Sharia Badge
                _ShariaBadge(l10n: l10n),

                const SizedBox(height: 16),

                // Social Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialBtn(
                      icon: Icons.people_outline_rounded,
                      tooltip: 'LinkedIn',
                    ),
                    const SizedBox(width: 12),
                    _SocialBtn(
                      icon: Icons.play_circle_fill_rounded,
                      tooltip: 'YouTube',
                    ),
                    const SizedBox(width: 12),
                    _SocialBtn(
                      icon: Icons.facebook_rounded,
                      tooltip: 'Facebook',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Copyright
                Text(
                  l10n.copyright,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen.withValues(alpha: 0.45),
                    fontFamily: 'IBMPlexArabic',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'تأميني جزاد — جميع الحقوق محفوظة © 2026',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryGreen.withValues(alpha: 0.35),
                    fontFamily: 'IBMPlexArabic',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildMobileTop(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Logo + Brand
        _BrandBlock(l10n: l10n),
        const SizedBox(height: 28),

        // Links — two columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterSectionTitle(title: l10n.aboutUs),
                  const SizedBox(height: 10),
                  _FooterLink(label: l10n.aboutUs, route: AppRoutes.about),
                  _FooterLink(
                    label: l10n.howTakafulWorks,
                    route: AppRoutes.howTakafulWorks,
                  ),
                  _FooterLink(
                    label: l10n.legalFramework,
                    route: AppRoutes.legalFramework,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterSectionTitle(title: l10n.support),
                  const SizedBox(height: 10),
                  _FooterLink(label: l10n.support, route: AppRoutes.support),
                  _FooterLink(label: l10n.faq, route: AppRoutes.faq),
                  _FooterLink(
                    label: l10n.contactUs,
                    route: AppRoutes.contactUs,
                  ),
                  _FooterLink(
                    label: l10n.privacyPolicy,
                    route: AppRoutes.privacyPolicy,
                  ),
                  _FooterLink(
                    label: l10n.termsAndConditions,
                    route: AppRoutes.termsAndConditions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopTop(
    BuildContext context,
    AppLocalizations l10n,
    double sw,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand block — 35% width
        Expanded(flex: 35, child: _BrandBlock(l10n: l10n)),
        const SizedBox(width: 40),

        // About column
        Expanded(
          flex: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FooterSectionTitle(title: l10n.aboutUs),
              const SizedBox(height: 12),
              _FooterLink(label: l10n.aboutUs, route: AppRoutes.about),
              _FooterLink(
                label: l10n.howTakafulWorks,
                route: AppRoutes.howTakafulWorks,
              ),
              _FooterLink(
                label: l10n.legalFramework,
                route: AppRoutes.legalFramework,
              ),
            ],
          ),
        ),

        // Support column
        Expanded(
          flex: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FooterSectionTitle(title: l10n.support),
              const SizedBox(height: 12),
              _FooterLink(label: l10n.support, route: AppRoutes.support),
              _FooterLink(label: l10n.faq, route: AppRoutes.faq),
              _FooterLink(label: l10n.contactUs, route: AppRoutes.contactUs),
            ],
          ),
        ),

        // Legal column
        Expanded(
          flex: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FooterSectionTitle(title: 'القانوني'),
              const SizedBox(height: 12),
              _FooterLink(
                label: l10n.privacyPolicy,
                route: AppRoutes.privacyPolicy,
              ),
              _FooterLink(
                label: l10n.termsAndConditions,
                route: AppRoutes.termsAndConditions,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Brand Block ─────────────────────────────────────────────────────────────
class _BrandBlock extends StatelessWidget {
  final AppLocalizations l10n;
  const _BrandBlock({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo icon + name
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.goldAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  l10n.shariaInsuranceSubtitle,
                  style: TextStyle(
                    fontFamily: 'IBMPlexArabic',
                    fontSize: 11,
                    color: AppColors.primaryGreen.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Short description
        Text(
          'تأمين تكافلي حلال 100% مطابق لأحكام الشريعة الإسلامية تحت إشراف الهيئة الشرعية الوطنية.',
          style: TextStyle(
            fontFamily: 'IBMPlexArabic',
            fontSize: 13,
            color: AppColors.primaryGreen.withValues(alpha: 0.60),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _FooterSectionTitle extends StatelessWidget {
  final String title;
  const _FooterSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'IBMPlexArabic',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Footer Link ─────────────────────────────────────────────────────────────
class _FooterLink extends StatelessWidget {
  final String label;
  final String route;

  const _FooterLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBMPlexArabic',
            fontSize: 13,
            color: AppColors.primaryGreen.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

// ─── Sharia Badge ────────────────────────────────────────────────────────────
class _ShariaBadge extends StatelessWidget {
  final AppLocalizations l10n;
  const _ShariaBadge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.07),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.40),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🕌', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            l10n.shariaCompliant,
            style: const TextStyle(
              fontFamily: 'IBMPlexArabic',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Social Button ───────────────────────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _SocialBtn({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $tooltip...'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
      ),
    );
  }
}
