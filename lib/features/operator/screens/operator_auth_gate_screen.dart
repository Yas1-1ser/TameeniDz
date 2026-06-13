import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/responsive_layout.dart';

class OperatorAuthGateScreen extends StatelessWidget {
  const OperatorAuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.beigeBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.darkText,
            size: 24,
          ),
          onPressed: () => context.go('/role'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: PageEntryAnimation(
        child: Stack(
          children: [
            // ── Champagne canvas background ───────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colors.beigeBg, Color(0xFFF0E9DD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Ambient auras ─────────────────────────────────────────────────
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withValues(alpha: 0.04),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 4.seconds,
                    curve: Curves.easeInOut,
                  ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldAccent.withValues(alpha: 0.04),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(0.9, 0.9),
                    duration: 5.seconds,
                    curve: Curves.easeInOut,
                  ),
            ),

            // ── Core content ──────────────────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ResponsiveWidthConstraint(
                    maxWidth: 480,
                    child: Column(
                      children: [
                        // Header
                        Column(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryGreen.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primaryGreen.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.business_center_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 36,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.operatorPortal,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: context.colors.darkText,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.chooseCompanyPrompt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: context.colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(
                              begin: const Offset(0.92, 0.92),
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 36),

                        // Algeria Takaful card
                        _CompanyAuthCard(
                              name:
                                  AppLocalizations.of(context)!.algeriaTakaful,
                              subtitle: 'Algeria Takaful Subtitle',
                              color: AppColors.primaryGreen,
                              icon: Icons.shield_rounded,
                              onLogin: () => context.go('/at/login'),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 150.ms)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 20),

                        // Al-Ittihad card
                        _CompanyAuthCard(
                              name: AppLocalizations.of(context)!.alIttihad,
                              subtitle: 'Al-Ittihad Subtitle',
                              color: AppColors.alIttihadGreen,
                              icon: Icons.verified_user_rounded,
                              onLogin: () => context.go('/ai/login'),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 280.ms)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 36),

                        // Support note
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: context.colors.surface.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: context.colors.warmDivider.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.help_outline_rounded,
                                      color: AppColors.goldAccent,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.needHelp,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.bold,
                                            color: context.colors.darkText,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.contactSupportTeam,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color:
                                                context.colors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Company auth card ─────────────────────────────────────────────────────────

class _CompanyAuthCard extends StatefulWidget {
  final String name;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onLogin;

  const _CompanyAuthCard({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onLogin,
  });

  @override
  State<_CompanyAuthCard> createState() => _CompanyAuthCardState();
}

class _CompanyAuthCardState extends State<_CompanyAuthCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(
            alpha: _hovered ? 0.95 : 0.85,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                _hovered
                    ? widget.color.withValues(alpha: 0.4)
                    : context.colors.warmDivider.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _hovered ? 0.12 : 0.06),
              blurRadius: _hovered ? 24 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Upper branding strip
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 26),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: context.colors.darkText,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Login
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded, size: 16),
                  label: Text(
                    AppLocalizations.of(context)!.loginAction,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
