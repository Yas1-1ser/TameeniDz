import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/beige_bg_decoration.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/responsive_layout.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

/// Premium operator portal picker — Algeria Takaful vs Al-Ittihad.
class OperatorSelectionScreen extends StatelessWidget {
  const OperatorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.darkText,
            size: 20,
          ),
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
        title: Text(
          l10n.chooseTakafulCompany,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colors.darkText,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: PageEntryAnimation(
        child: BeigeBgDecoration(
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.25),
                      radius: 1.35,
                      colors: [
                        const Color(0xFFFFFDF9),
                        colors.beigeBg,
                        const Color(0xFFF0E9DD),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(child: _GoldPatternBg()),
              Positioned(
                top: -90,
                right: -70,
                child: _PulsingGlow(
                  size: 260,
                  color: AppColors.goldAccent.withValues(alpha: 0.07),
                  delayMs: 0,
                ),
              ),
              Positioned(
                bottom: -60,
                left: -80,
                child: _PulsingGlow(
                  size: 220,
                  color: AppColors.primaryGreen.withValues(alpha: 0.05),
                  delayMs: 400,
                ),
              ),
              SafeArea(
                child: ResponsiveWidthConstraint(
                  maxWidth: 520,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: Column(
                      children: [
                        _buildHeader(context, l10n),
                        const SizedBox(height: 36),
                        _OperatorPickCard(
                          icon: Icons.shield_moon_rounded,
                          title: l10n.algeriaTakafulPortal,
                          subtitle: 'Algeria Takaful',
                          badge: l10n.operatorTakaful,
                          description: l10n.decreeComplianceFootnote,
                          accentColor: AppColors.primaryGreen,
                          entranceDelay: 120,
                          onTap: () {
                            Feedback.forTap(context);
                            context.push(AppRoutes.atLogin);
                          },
                        ),
                        const SizedBox(height: 18),
                        _OperatorPickCard(
                          icon: Icons.handshake_rounded,
                          title: l10n.alIttihadPortal,
                          subtitle: 'Al-Ittihad',
                          badge: l10n.algeriaUnited,
                          description: l10n.decreeComplianceFootnote,
                          accentColor: AppColors.alIttihadGreen,
                          entranceDelay: 240,
                          logoAsset: 'assets/images/logotameen.jpg',
                          onTap: () {
                            Feedback.forTap(context);
                            context.push(AppRoutes.aiLogin);
                          },
                        ),
                        const SizedBox(height: 28),
                        _HelpCard(l10n: l10n)
                            .animate()
                            .fadeIn(delay: 420.ms, duration: 500.ms)
                            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 28),
                        Opacity(
                          opacity: 0.55,
                          child: Text(
                            l10n.footerText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.slate500,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ).animate().fadeIn(delay: 520.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldAccent.withValues(alpha: 0.3),
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.07, 1.07),
                  duration: 2200.ms,
                  curve: Curves.easeInOutSine,
                ),
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.goldAccent.withValues(alpha: 0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logotameen.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colors.surface,
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.goldAccent,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldAccent.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.goldAccent,
                  size: 16,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  duration: 3000.ms,
                  begin: -0.05,
                  end: 0.05,
                  curve: Curves.easeInOut,
                ),
          ],
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.85, 0.85),
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 20),
        Text(
          l10n.selectCompanyFirst,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: colors.slate500,
            fontWeight: FontWeight.w800,
            fontFamily: 'Cairo',
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.06, end: 0),
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldAccent, Color(0xFFE8D5A0)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate().fadeIn(delay: 220.ms).scaleX(begin: 0, end: 1),
      ],
    );
  }
}

// ── Animated gold ambient orb ─────────────────────────────────────────────────

class _PulsingGlow extends StatelessWidget {
  const _PulsingGlow({
    required this.size,
    required this.color,
    required this.delayMs,
  });

  final double size;
  final Color color;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.08, 1.08),
          delay: Duration(milliseconds: delayMs),
          duration: 4500.ms,
          curve: Curves.easeInOutSine,
        )
        .fadeIn(duration: 800.ms);
  }
}

// ── Operator company card ─────────────────────────────────────────────────────

class _OperatorPickCard extends StatefulWidget {
  const _OperatorPickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.description,
    required this.accentColor,
    required this.onTap,
    required this.entranceDelay,
    this.logoAsset,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;
  final int entranceDelay;
  final String? logoAsset;

  @override
  State<_OperatorPickCard> createState() => _OperatorPickCardState();
}

class _OperatorPickCardState extends State<_OperatorPickCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final active = _pressed || _hovered;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : (_hovered ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.goldAccent.withValues(
                  alpha: active ? 0.75 : 0.32,
                ),
                width: active ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: active ? 24 : 16,
                  offset: Offset(0, active ? 8 : 5),
                ),
                BoxShadow(
                  color: AppColors.goldAccent.withValues(
                    alpha: active ? 0.16 : 0.06,
                  ),
                  blurRadius: active ? 28 : 12,
                  offset: const Offset(0, 4),
                ),
                if (active)
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    blurRadius: 18,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.accentColor.withValues(alpha: 0.14),
                            AppColors.goldAccent.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(
                            alpha: active ? 0.45 : 0.22,
                          ),
                        ),
                      ),
                      child: widget.logoAsset != null
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                widget.logoAsset!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(widget.icon, color: widget.accentColor, size: 30),
                              ),
                            )
                          : Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 30,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(
                          duration: 2400.ms,
                          color: AppColors.goldAccent.withValues(alpha: 0.12),
                        ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isRtl
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: colors.darkText,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.accentColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        widget.badge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldAccent,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.goldAccent.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.goldAccent.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.slate500,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.accentColor,
                              Color.lerp(
                                widget.accentColor,
                                AppColors.primaryGreen,
                                0.25,
                              )!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: AppColors.goldAccent.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(
                                alpha: active ? 0.35 : 0.22,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.login,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.goldAccent.withValues(alpha: 0.14)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(
                            alpha: active ? 0.5 : 0.25,
                          ),
                        ),
                      ),
                      child: Icon(
                        isRtl
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: active
                            ? widget.accentColor
                            : AppColors.goldAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 450.ms,
          delay: Duration(milliseconds: widget.entranceDelay),
        )
        .slideY(
          begin: 0.14,
          end: 0,
          duration: 450.ms,
          delay: Duration(milliseconds: widget.entranceDelay),
          curve: Curves.easeOutCubic,
        )
        .then(delay: 180.ms)
        .shimmer(
          duration: 1000.ms,
          color: AppColors.goldAccent.withValues(alpha: 0.15),
        );
  }
}

// ── Help card ─────────────────────────────────────────────────────────────────

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.beigeCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldAccent.withValues(alpha: 0.18),
                  AppColors.goldAccent.withValues(alpha: 0.06),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldAccent.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.goldAccent,
              size: 26,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 1800.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.needHelp,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: colors.darkText,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.contactSupportTeam,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.slate500,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.goldAccent.withValues(alpha: 0.85),
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ── Subtle rotating gold pattern ──────────────────────────────────────────────

class _GoldPatternBg extends StatefulWidget {
  const _GoldPatternBg();

  @override
  State<_GoldPatternBg> createState() => _GoldPatternBgState();
}

class _GoldPatternBgState extends State<_GoldPatternBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 70),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _GoldTilePainter(angle: _ctrl.value * 2 * math.pi),
      ),
    );
  }
}

class _GoldTilePainter extends CustomPainter {
  _GoldTilePainter({required this.angle});
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9A84C).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    const spacing = 76.0;
    final cols = (size.width / spacing).ceil() + 2;
    final rows = (size.height / spacing).ceil() + 2;

    for (var r = -1; r < rows; r++) {
      for (var c = -1; c < cols; c++) {
        final cx = c * spacing + spacing / 2;
        final cy = r * spacing + spacing / 2;
        _star(canvas, paint, Offset(cx, cy), 20, angle);
      }
    }
  }

  void _star(Canvas canvas, Paint paint, Offset c, double r, double rot) {
    const n = 8;
    final inner = r * 0.45;
    final path = Path();
    for (var i = 0; i < n * 2; i++) {
      final rad = i.isEven ? r : inner;
      final a = (i * math.pi / n) + rot;
      final x = c.dx + rad * math.cos(a);
      final y = c.dy + rad * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GoldTilePainter old) => old.angle != angle;
}
