import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../shared/widgets/responsive_layout.dart';

/// Splash / landing screen.
///
/// Fixes applied:
///  - Real custom logo widget (shield + crescent + star)
///  - Animated logo entrance (scale + fade in)
///  - Language switcher wired to localeProvider (AR / TZM / FR / EN)
///  - Styled CTA button
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const _languages = [
    ('AR', 'ar'),
    ('TZM', 'kab'),
    ('FR', 'fr'),
    ('EN', 'en'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: ResponsiveWidthConstraint(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // ── Language switcher pill ───────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    _languages.map((lang) {
                                      final isActive =
                                          currentLocale.languageCode == lang.$2;
                                      return GestureDetector(
                                        onTap:
                                            () => ref
                                                .read(localeProvider.notifier)
                                                .setLocale(Locale(lang.$2)),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isActive
                                                    ? context.colors.surface
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              40,
                                            ),
                                            boxShadow:
                                                isActive
                                                    ? [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .primaryGreen
                                                            .withValues(
                                                              alpha: 0.10,
                                                            ),
                                                        blurRadius: 6,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child: Text(
                                            lang.$1,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  isActive
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                              color:
                                                  isActive
                                                      ? AppColors.primaryGreen
                                                      : context.colors.slate500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // ── Animated Logo ─────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _TaminyLogoWidget(),
                                const SizedBox(height: 24),
                                Text(
                                  AppLocalizations.of(context)!.splashKeywords,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.colors.slate500,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // ── Start button ──────────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            debugPrint(
                              'DEBUG: SplashScreen button tapped, navigating to /role',
                            );
                            context.go('/role');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.login,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Taminy Logo Widget
// ─────────────────────────────────────────────────────────────────────────────

class _TaminyLogoWidget extends StatelessWidget {
  const _TaminyLogoWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('assets/images/logotameen.jpeg', fit: BoxFit.cover),
    );
  }
}
