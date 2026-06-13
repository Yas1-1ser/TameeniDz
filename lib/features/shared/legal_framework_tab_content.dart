import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/about/legal_card.dart';
import 'package:tameenidz/features/shared/widgets/about/principle_tile.dart';

class LegalFrameworkTabContent extends StatelessWidget {
  const LegalFrameworkTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            if (context.findAncestorWidgetOfExactType<NestedScrollView>() !=
                null)
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Section title with animated underline
                  _AnimatedTitleWithUnderline(
                    title: AppLocalizations.of(context)!.whyLegalFramework,
                  ),
                  const SizedBox(height: 24),

                  // Legal cards
                  LegalCard(
                    title: AppLocalizations.of(context)!.insuranceLaw,
                    body: AppLocalizations.of(context)!.insuranceLawDesc,
                    icon: '📜',
                    delayMs: 100,
                  ),
                  LegalCard(
                    title: AppLocalizations.of(context)!.shariaSupervision,
                    body: AppLocalizations.of(context)!.shariaSupervisionDesc,
                    icon: '⚖️',
                    delayMs: 200,
                    bulletPoints: [
                      AppLocalizations.of(context)!.auditAnnual,
                      AppLocalizations.of(context)!.productAccreditation,
                    ],
                  ),
                  LegalCard(
                    title: AppLocalizations.of(context)!.internationalStandards,
                    body:
                        AppLocalizations.of(
                          context,
                        )!.internationalStandardsDesc,
                    icon: '🏛️',
                    delayMs: 300,
                  ),

                  // Principles title
                  Text(
                        AppLocalizations.of(context)!.islamicPrinciples,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.colors.darkText,
                        ),
                      )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms),
                  const SizedBox(height: 16),

                  // 2×2 Principles grid
                  const _PrinciplesGrid(),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Animated Title with Underline
// ──────────────────────────────────────────────────────────────────────────────
class _AnimatedTitleWithUnderline extends StatefulWidget {
  final String title;

  const _AnimatedTitleWithUnderline({required this.title});

  @override
  State<_AnimatedTitleWithUnderline> createState() =>
      _AnimatedTitleWithUnderlineState();
}

class _AnimatedTitleWithUnderlineState
    extends State<_AnimatedTitleWithUnderline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _underlineWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _underlineWidth = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: context.colors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _underlineWidth,
          builder: (_, __) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth * _underlineWidth.value * 0.5,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.takafulGreen, Color(0xFF2E8B57)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 2×2 Principles Grid
// ──────────────────────────────────────────────────────────────────────────────
class _PrinciplesGrid extends StatelessWidget {
  const _PrinciplesGrid();

  @override
  Widget build(BuildContext context) {
    final principles = [
      {
        'icon': '⚖️',
        'title': AppLocalizations.of(context)!.equality,
        'desc': AppLocalizations.of(context)!.equalityDesc,
        'delay': 500,
      },
      {
        'icon': '🕌',
        'title': AppLocalizations.of(context)!.honesty,
        'desc': AppLocalizations.of(context)!.honestyDesc,
        'delay': 600,
      },
      {
        'icon': '🛡️',
        'title': AppLocalizations.of(context)!.solidarity,
        'desc': AppLocalizations.of(context)!.solidarityDesc,
        'delay': 700,
      },
      {
        'icon': '🤝',
        'title': AppLocalizations.of(context)!.transparency,
        'desc': AppLocalizations.of(context)!.transparencyDesc,
        'delay': 800,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: principles.length,
      itemBuilder: (context, i) {
        final p = principles[i];
        return PrincipleTile(
          icon: p['icon'] as String,
          title: p['title'] as String,
          description: p['desc'] as String,
          delayMs: p['delay'] as int,
        );
      },
    );
  }
}
