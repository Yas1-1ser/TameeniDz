import 'dart:math';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import '../../../core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/responsive_layout.dart';
import '../widgets/floating_particles.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Breathtaking, high-fidelity premium Splash / landing screen for Tameeni Elite.
///
/// Refined with:
///  - Ambient golden floating particles
///  - Premium Language Selector opening a glassmorphic floating modal
///  - Concentric rotating gold rings framing a floating logo centerpiece
///  - Shimmering gradient CTA button with tactile spring scaling
///
/// Root cause #2 fix: uses AppLocalizations (from .arb) instead of easy_localization.
/// Root cause #2 fix: CTA navigates to /role, not /onboarding (which is itself).
/// Root cause #2 fix: outer/inner rotating rings layout builder scaled to prevent overflow.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      body: PageEntryAnimation(
        child: Stack(
          children: [
            // ── Ambient Background & Floating Particles ────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.2),
                    radius: 1.4,
                    colors: [
                      Color(0xFFFFFDF9), // Deep champagne core
                      Color(0xFFF9F6F0), // Luxury beige transition
                      Color(0xFFF2ECE0), // Soft warm shadow background
                    ],
                  ),
                ),
              ),
            ),

            // Glowing radial gradient behind logo
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldAccent.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 1000.ms),
            ),

            // Gentle ambient golden particles floating up
            const Positioned.fill(
              child: FloatingParticles(count: 14, color: AppColors.goldAccent),
            ),

            // ── Main Page Content ──────────────────────────────────────────────
            SafeArea(
              child: ResponsiveWidthConstraint(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - kToolbarHeight - 60,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // ── Canonical Language Selector ────────────────────
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: LanguagePickerButton(
                                      textColor: AppColors.primaryGreen,
                                      iconColor: AppColors.primaryGreen,
                                      borderColor: AppColors.primaryGreen,
                                      backgroundColor: context.colors.beigeBg,
                                    )
                                    .animate()
                                    .fadeIn(duration: 800.ms, delay: 200.ms)
                                    .slideY(
                                      begin: -0.2,
                                      end: 0,
                                      curve: Curves.easeOutBack,
                                    ),
                              ),
                            ),

                            const Spacer(flex: 2),

                            // ── Luxury Floating Logo Centerpiece ───────────────
                            _buildLogoCenterpiece(context),

                            const Spacer(flex: 3),

                            // ── Elegant Animated Slogan & Keywords ─────────────
                            _buildSloganAndBranding(context, l10n),

                            const Spacer(flex: 2),

                            // ── Shimmering Gradient CTA Button ─────────────────
                            _buildCTAButton(context, l10n),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),

                      // ── App Footer ────────────────────────────────────────────
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCenterpiece(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
              builder: (context, constraints) {
                final outerDiam = min(constraints.maxWidth * 0.52, 210.0);
                final innerDiam = outerDiam - 18;
                final logoDiam = outerDiam - 42;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer golden elegant dashed ring (rotated continuously)
                    RotationTransition(
                          turns: const AlwaysStoppedAnimation(45 / 360),
                          child: Container(
                            width: outerDiam,
                            height: outerDiam,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 35.seconds, begin: 0, end: 1),

                    // Inner golden accent glow ring
                    Container(
                      width: innerDiam,
                      height: innerDiam,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.55),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldAccent.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // Actual Logo widget inside a beautiful frame
                    Container(
                      width: logoDiam,
                      height: logoDiam,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.surface,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logotameen.jpg',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: AppColors.primaryContainer,
                              child: Icon(
                                Icons.shield_rounded,
                                size: logoDiam * 0.52,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                      ),
                    ),
                  ],
                );
              },
            )
            .animate()
            .scale(
              begin: const Offset(0.85, 0.85),
              duration: 800.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 600.ms)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(
              begin: -6,
              end: 6,
              duration: 2200.ms,
              curve: Curves.easeInOutSine,
            ),
      ],
    );
  }

  Widget _buildSloganAndBranding(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Title — uses AppLocalizations, not easy_localization
        Text(
              l10n.appTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
                letterSpacing: 2.0,
                fontFamily: 'Cairo',
                shadows: [
                  Shadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

        const SizedBox(height: 12),

        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.goldAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate().fadeIn(delay: 500.ms).scaleX(begin: 0, end: 1),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            l10n.splashKeywords,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.slate700,
              fontWeight: FontWeight.w700,
              height: 1.6,
              fontFamily: 'Cairo',
              letterSpacing: 0.5,
            ),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildCTAButton(BuildContext context, AppLocalizations l10n) {
    return AnimatedScale(
          scale: _isButtonPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isButtonPressed = true),
            onTapUp: (_) => setState(() => _isButtonPressed = false),
            onTapCancel: () => setState(() => _isButtonPressed = false),
            onTap: () {
              // Fix: navigate to /welcome (onboarding carousel), NOT /onboarding (this screen)
              context.go('/welcome');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF247E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppColors.goldAccent.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.getStarted.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: context.colors.surface,
                      letterSpacing: 1.2,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: context.colors.surface,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 800.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack)
        .shimmer(delay: 1500.ms, duration: 1800.ms);
  }
}
