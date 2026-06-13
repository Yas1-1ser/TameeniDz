import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
// lib/screens/about/legal_framework_screen.dart
import 'package:flutter/material.dart';

import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/app_scaffold.dart';
import 'package:tameenidz/features/shared/legal_framework_tab_content.dart';

/// Exported for use as a tab content inside HowTakafulWorksScreen.

/// Standalone screen (can be navigated to directly from router).
class LegalFrameworkScreen extends StatelessWidget {
  const LegalFrameworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppLocalizations.of(context)!.legalFramework,
      body: PageEntryAnimation(child: const LegalFrameworkTabContent()),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Animated Title with Underline
// ──────────────────────────────────────────────────────────────────────────────
class _AnimatedTitleWithUnderline extends StatefulWidget {
  final String title;
  final bool isRtl;

  const _AnimatedTitleWithUnderline({required this.title, required this.isRtl});

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
      crossAxisAlignment:
          widget.isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: context.colors.darkText,
          ),
          textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
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

