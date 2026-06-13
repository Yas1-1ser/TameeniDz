import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/core/providers/locale_provider.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/royale_widgets.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/core/router/app_routes.dart';

/// Highly modernized premium Onboarding Screen (3 slides) for Tameeni Elite.
///
/// Elevated with:
///  - Consumer State tracking for live locale changes.
///  - Premium Language picker circle button in the header.
///  - Floating ambient blur spheres in the background.
///  - Re-triggerable slide animations via ValueKey page index tracking.

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isNextPressed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    debugPrint(
      'DEBUG: Onboarding completed, setting flag and navigating to role selection.',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go(AppRoutes.roleSelection);
  }

  Widget _buildPage({
    required int index,
    required IconData icon,
    required Color iconColor,
    required Color circleColor,
    required IconData badgeIcon,
    required Color badgeBgColor,
    required String tag,
    required String title,
    required String subtitle,
  }) {
    // Adding ValueKey triggers animations to re-play on every single page transition!
    final keyPrefix = 'slide_${index}_${_currentPage == index}';

    return Column(
      children: [
        // ── Illustration Area ──────────────────────────────────────────────
        Expanded(
          flex: 46,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft background radial glow
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        circleColor.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Concentric elegant gold rings
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.warmDivider.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                ),

                // Large outer circle
                Container(
                  key: ValueKey('${keyPrefix}_outer'),
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.warmDivider.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),

                // Secondary inner circle - Optimized with RepaintBoundary
                RepaintBoundary(
                  child: Container(
                        key: ValueKey('${keyPrefix}_inner'),
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(icon, size: 72, color: iconColor),
                        ),
                      )
                      .animate()
                      .scale(
                        duration: 600.ms,
                        delay: 150.ms,
                        curve: Curves.easeOutBack,
                      )
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .moveY(
                        begin: -5,
                        end: 5,
                        duration: 2000.ms,
                        curve: Curves.easeInOutSine,
                      ),
                ),

                // Floating badge - Optimized with RepaintBoundary
                Positioned(
                  top: 35,
                  right: 35,
                  child: RepaintBoundary(
                    child: Container(
                          key: ValueKey('${keyPrefix}_badge'),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(badgeIcon, color: Colors.white, size: 20),
                        )
                        .animate()
                        .slide(
                          begin: const Offset(1.5, -1.5),
                          duration: 950.ms,
                          delay: 450.ms,
                          curve: Curves.easeOutBack,
                        )
                        .animate(
                          onPlay:
                              (controller) => controller.repeat(reverse: true),
                        )
                        .rotate(duration: 4000.ms, begin: -0.05, end: 0.05),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Elegant Content Card ───────────────────────────────────────────
        Expanded(
          flex: 54,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  key: ValueKey('${keyPrefix}_card'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: context.colors.warmDivider.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag Chip
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldAccent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(
                                  alpha: 0.35,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.goldAccent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 100.ms)
                          .scaleX(begin: 0.7, end: 1.0),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: context.colors.darkText,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 250.ms)
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            curve: Curves.easeOutBack,
                          ),

                      const SizedBox(height: 14),

                      // Description Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.5,
                          color: context.colors.onSurfaceVariant,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 700.ms, delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch localeProvider to ensure 100% reactive, instantaneous rebuilds on language change
    final localeState = ref.watch(localeProvider);
    final locale = localeState.languageCode;

    // Slide 1
    final slide1Tag =
        locale == 'ar'
            ? 'حلال 100%'
            : (locale == 'fr'
                ? '100% Halal'
                : (locale == 'kab' ? '100% Lḥelal' : '100% Halal'));
    final slide1Title =
        locale == 'ar'
            ? 'مرحباً بكم في تأميني إيليت'
            : (locale == 'fr'
                ? 'Bienvenue sur Tameeni Elite'
                : (locale == 'kab'
                    ? 'Ansuf ɣer Tameeni Elite'
                    : 'Welcome to Tameeni Elite'));
    final slide1Sub =
        locale == 'ar'
            ? 'حماية تعاونية إسلامية سيادية بأعلى معايير الشفافية'
            : (locale == 'fr'
                ? 'Protection Coopérative Islamique Souveraine'
                : (locale == 'kab'
                    ? 'Aḥraz n Takaful n Lḥelal ameqqran'
                    : 'Sovereign Islamic Cooperative Protection'));

    // Slide 2
    final slide2Tag =
        locale == 'ar'
            ? 'تغطية متنوعة'
            : (locale == 'fr'
                ? 'Protection Diversifiée'
                : (locale == 'kab'
                    ? 'Aḥraz yemgareden'
                    : 'Diverse Protection'));
    final slide2Title =
        locale == 'ar'
            ? 'درع حماية متكامل'
            : (locale == 'fr'
                ? 'Bouclier Complet'
                : (locale == 'kab'
                    ? 'Tastut tameqqrant'
                    : 'Comprehensive Shielding'));
    final slide2Sub =
        locale == 'ar'
            ? 'من المساعدة على الطريق إلى الرعاية الصحية، مصمم خصيصاً لتلبية احتياجاتك'
            : (locale == 'fr'
                ? "De l'assistance routière au médical, adapté pour vous"
                : (locale == 'kab'
                    ? 'Seg tallalt n ubrid ɣer ṭṭbib, i kečč kan'
                    : 'From roadside help to medical, tailored for you'));

    // Slide 3
    final slide3Tag =
        locale == 'ar'
            ? 'رقمنة 100%'
            : (locale == 'fr'
                ? '100% Numérique'
                : (locale == 'kab' ? '100% Antirnet' : '100% Digital'));
    final slide3Title =
        locale == 'ar'
            ? 'سرعة وأمان رقمي'
            : (locale == 'fr'
                ? 'Rapidité Numérique'
                : (locale == 'kab'
                    ? 'Lfeṭna n ubrid n internet'
                    : 'Sovereign Digital Speed'));
    final slide3Sub =
        locale == 'ar'
            ? 'معالجة سريعة، تقديم مطالبات عبر الإنترنت، وتوزيع شفاف للفائض'
            : (locale == 'fr'
                ? 'Traitement rapide, sinistres en ligne et surplus transparent'
                : (locale == 'kab'
                    ? 'Aheggi n tewriqin s tazzla, asureg n tilla d lfaida izezzigen'
                    : 'Fast processing, online claims, and fully transparent surplus'));

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      body: PageEntryAnimation(
        child: Stack(
          children: [
            // ── Ambient Background Canvas ──────────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colors.beigeBg, context.colors.beigeBg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Upper-left soft decorative aura (Float animation) - Optimized with RepaintBoundary
            Positioned(
              top: -90,
              left: -90,
              child: RepaintBoundary(
                child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.goldAccent.withValues(alpha: 0.05),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 4.seconds,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),

            // Lower-right soft decorative aura (Float animation) - Optimized with RepaintBoundary
            Positioned(
              bottom: -90,
              right: -90,
              child: RepaintBoundary(
                child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen.withValues(alpha: 0.03),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(0.9, 0.9),
                      duration: 5.seconds,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),

            // Core UI Flow
            SafeArea(
              child: Column(
                children: [
                  // ── Top Header Actions (Language Selector & Skip Button) ──────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Canonical language button
                        LanguagePickerButton(
                          textColor: AppColors.primaryGreen,
                          iconColor: AppColors.primaryGreen,
                          borderColor: AppColors.primaryGreen,
                          backgroundColor: context.colors.beigeBg,
                        ),

                        // Skip Button
                        AnimatedOpacity(
                          opacity: _currentPage < 2 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: _currentPage >= 2,
                            child: SpringButton(
                              child: TextButton(
                                onPressed: _finishOnboarding,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: context.colors.warmDivider
                                          .withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  backgroundColor: context.colors.beigeBg
                                      .withValues(alpha: 0.45),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.skip.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: context.colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Carousel Page View ─────────────────────────────────────────
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged:
                          (index) => setState(() => _currentPage = index),
                      children: [
                        _buildPage(
                          index: 0,
                          icon: Icons.security_rounded,
                          iconColor: AppColors.primaryGreen,
                          circleColor: AppColors.primaryGreen.withValues(
                            alpha: 0.1,
                          ),
                          badgeIcon: Icons.verified_user_rounded,
                          badgeBgColor: AppColors.goldAccent,
                          tag: slide1Tag,
                          title: slide1Title,
                          subtitle: slide1Sub,
                        ),
                        _buildPage(
                          index: 1,
                          icon: Icons.family_restroom_rounded,
                          iconColor: AppColors.goldAccent,
                          circleColor: AppColors.goldAccent.withValues(
                            alpha: 0.1,
                          ),
                          badgeIcon: Icons.favorite_rounded,
                          badgeBgColor: AppColors.primaryGreen,
                          tag: slide2Tag,
                          title: slide2Title,
                          subtitle: slide2Sub,
                        ),
                        _buildPage(
                          index: 2,
                          icon: Icons.speed_rounded,
                          iconColor: AppColors.primaryGreen,
                          circleColor: AppColors.primaryGreen.withValues(
                            alpha: 0.1,
                          ),
                          badgeIcon: Icons.bolt_rounded,
                          badgeBgColor: AppColors.goldAccent,
                          tag: slide3Tag,
                          title: slide3Title,
                          subtitle: slide3Sub,
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom Page Indicators & Shimmering CTA Button ──────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Expanding glow indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isSelected = _currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: isSelected ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.goldAccent
                                        : context.colors.warmDivider.withValues(
                                          alpha: 0.6,
                                        ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: AppColors.goldAccent
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                        : [
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            blurRadius: 0,
                                            spreadRadius: 0,
                                          ),
                                        ],
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Styled interactive shimmering button
                        AnimatedScale(
                              scale: _isNextPressed ? 0.97 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: GestureDetector(
                                onTapDown:
                                    (_) =>
                                        setState(() => _isNextPressed = true),
                                onTapUp:
                                    (_) =>
                                        setState(() => _isNextPressed = false),
                                onTapCancel:
                                    () =>
                                        setState(() => _isNextPressed = false),
                                child: PrimaryButton(
                                  text:
                                      _currentPage == 2
                                          ? AppLocalizations.of(
                                            context,
                                          )!.getStarted.toUpperCase()
                                          : AppLocalizations.of(
                                            context,
                                          )!.next.toUpperCase(),
                                  onPressed: () {
                                    if (_currentPage == 2) {
                                      _finishOnboarding();
                                    } else {
                                      _pageController.nextPage(
                                        duration: 500.ms,
                                        curve: Curves.easeInOutCubic,
                                      );
                                    }
                                  },
                                ),
                              ),
                            )
                            .animate(target: _currentPage == 2 ? 1.0 : 0.0)
                            .shimmer(delay: 200.ms, duration: 1800.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
