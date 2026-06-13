import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../shared/widgets/page_entry_animation.dart';
import '../shared/widgets/responsive_layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class RolePickerScreen extends ConsumerWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      body: PageEntryAnimation(
        child: Stack(
          children: [
            // ── Ambient radial backdrop ──────────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.35),
                    radius: 1.4,
                    colors: [
                      Color(0xFFFFFDF9),
                      Color(0xFFF9F6F0),
                      Color(0xFFF2EBE0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Subtle rotating Islamic-pattern painter ──────────────────────
            const Positioned.fill(child: _IslamicPatternBg()),

            // ── Soft corner glows ────────────────────────────────────────────
            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldAccent.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withValues(alpha: 0.03),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────────
            SafeArea(
              child: ResponsiveWidthConstraint(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // ── Header: logo + title ─────────────────────────────
                      _buildHeader(context, l10n),

                      const SizedBox(height: 44),

                      // ── Role cards (staggered spring entrance) ───────────
                      _RoleCard(
                        icon: Icons.person_outline_rounded,
                        title: l10n.client,
                        subtitle: l10n.clientRoleSubtitle,
                        accentColor: AppColors.primaryGreen,
                        onTap: () {
                          Feedback.forTap(context);
                          context.go('/role/client');
                        },
                        entranceDelay: 80,
                      ),

                      const SizedBox(height: 16),

                      _RoleCard(
                        icon: Icons.business_rounded,
                        title: l10n.operatorRole,
                        subtitle: l10n.operatorRoleSubtitle,
                        accentColor: AppColors.subscriberFund,
                        onTap: () {
                          Feedback.forTap(context);
                          context.go('/role/operator');
                        },
                        entranceDelay: 180,
                      ),

                      const SizedBox(height: 16),

                      _RoleCard(
                        icon: Icons.admin_panel_settings_rounded,
                        title: l10n.adminRole,
                        subtitle: l10n.adminRoleSubtitle,
                        accentColor: AppColors.goldAccent,
                        onTap: () {
                          Feedback.forTap(context);
                          context.go('/admin/login');
                        },
                        entranceDelay: 280,
                      ),

                      const SizedBox(height: 52),

                      // ── Footer ────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Opacity(
                          opacity: 0.55,
                          child: Text(
                            l10n.footerText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.slate500,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
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

  // ── Header with REAL logo (no shield icon) ──────────────────────────────────
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Outer pulse ring + logo
        Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring (animated)
                Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.08, 1.08),
                      duration: 2200.ms,
                      curve: Curves.easeInOutSine,
                    ),

                // Inner gold ring
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldAccent.withValues(alpha: 0.65),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                // ── FIX ①: Real logo, no fallback shield ──────────────────
                Container(
                  width: 70,
                  height: 70,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surface,
                  ),
                  child: Image.asset(
                    'assets/images/logotameen.jpg',
                    fit: BoxFit.cover,
                    // Only falls back if the asset is literally missing from pubspec
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: AppColors.primaryContainer,
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.primaryGreen,
                            size: 32,
                          ),
                        ),
                  ),
                ),
              ],
            )
            .animate()
            .scale(
              duration: 650.ms,
              curve: Curves.easeOutBack,
              begin: const Offset(0.82, 0.82),
            )
            .fadeIn(duration: 500.ms),

        const SizedBox(height: 22),

        // App title
        Text(
              l10n.appTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
                letterSpacing: 1.8,
                fontFamily: 'Cairo',
              ),
            )
            .animate()
            .fadeIn(delay: 120.ms, duration: 500.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 6),

        // Gold divider bar
        Container(
          width: 36,
          height: 2.5,
          decoration: BoxDecoration(
            color: AppColors.goldAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate().fadeIn(delay: 180.ms).scaleX(begin: 0, end: 1),

        const SizedBox(height: 12),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.selectAccountTypeToProceed,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(delay: 240.ms),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium _RoleCard  (beige+gold, spring scale, shimmer on entry)
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    required this.entranceDelay,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final int entranceDelay;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = _pressed || _hovered;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            scale: _pressed ? 0.965 : (_hovered ? 1.018 : 1.0),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // ── FIX ④: Richer beige card base ──────────────────────
                  color: const Color(0xFFFFFBF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldAccent.withValues(
                      alpha: active ? 0.72 : 0.30,
                    ),
                    width: active ? 1.8 : 1.5,
                  ),
                  boxShadow: [
                    // Base soft shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.055),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                    // Gold glow — grows on press/hover
                    BoxShadow(
                      color: AppColors.goldAccent.withValues(
                        alpha: active ? 0.14 : 0.05,
                      ),
                      blurRadius: active ? 22 : 10,
                      offset: const Offset(0, 4),
                    ),
                    // Accent colour halo
                    if (active)
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── Icon pill ─────────────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(
                          alpha: active ? 0.16 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(
                            alpha: active ? 0.35 : 0.18,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 18),

                    // ── Text ──────────────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            isRtl
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: context.colors.darkText,
                              fontFamily: 'Cairo',
                            ),
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.slate500,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              fontFamily: 'Cairo',
                            ),
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ── Trailing chevron ──────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            active
                                ? widget.accentColor.withValues(alpha: 0.10)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        size: 20,
                        color:
                            active
                                ? widget.accentColor
                                : AppColors.goldAccent.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        // ── FIX ③: Spring entrance + shimmer on first appearance ─────────
        .animate()
        .fadeIn(
          duration: 420.ms,
          delay: Duration(milliseconds: widget.entranceDelay),
        )
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 420.ms,
          delay: Duration(milliseconds: widget.entranceDelay),
          curve: Curves.easeOutCubic,
        )
        .then(delay: 200.ms)
        .shimmer(
          duration: 900.ms,
          color: AppColors.goldAccent.withValues(alpha: 0.18),
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IslamicPatternBg  — lightweight custom painter, very subtle gold filigree
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicPatternBg extends StatefulWidget {
  const _IslamicPatternBg();

  @override
  State<_IslamicPatternBg> createState() => _IslamicPatternBgState();
}

class _IslamicPatternBgState extends State<_IslamicPatternBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotCtrl,
      builder:
          (_, __) => CustomPaint(
            painter: _IslamicTilePainter(angle: _rotCtrl.value * 2 * math.pi),
          ),
    );
  }
}

class _IslamicTilePainter extends CustomPainter {
  final double angle;
  const _IslamicTilePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFC9A84C).withValues(alpha: 0.045)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    const spacing = 72.0;
    final cols = (size.width / spacing).ceil() + 2;
    final rows = (size.height / spacing).ceil() + 2;

    for (var r = -1; r < rows; r++) {
      for (var c = -1; c < cols; c++) {
        final cx = c * spacing + spacing / 2;
        final cy = r * spacing + spacing / 2;
        _drawStar8(canvas, paint, Offset(cx, cy), 22, angle);
      }
    }
  }

  void _drawStar8(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
    double rotation,
  ) {
    const points = 8;
    final inner = radius * 0.48;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : inner;
      final a = (i * math.pi / points) + rotation;
      final x = center.dx + r * math.cos(a);
      final y = center.dy + r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicTilePainter old) => old.angle != angle;
}
