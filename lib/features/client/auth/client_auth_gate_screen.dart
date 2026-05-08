import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../shared/widgets/responsive_layout.dart';

/// Shown after the user picks "Client" on the role picker.
/// Lets them choose between logging in (existing account) or registering.
class ClientAuthGateScreen extends StatelessWidget {
  const ClientAuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveWidthConstraint(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        color: context.colors.darkText,
                        onPressed: () => context.go('/role'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Logo ─────────────────────────────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(60),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.clientPortalTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.colors.darkText,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.client,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.slate500,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      // ── Login card ────────────────────────────────
                      _AuthOptionCard(
                        icon: Icons.login_rounded,
                        title: AppLocalizations.of(context)!.login,
                        subtitle:
                            AppLocalizations.of(
                              context,
                            )!.existingAccountSubtitle,
                        isPrimary: true,
                        onTap: () => context.go('/client/login'),
                      ),
                      const SizedBox(height: 14),

                      // ── Register card ─────────────────────────────
                      _AuthOptionCard(
                        icon: Icons.person_add_outlined,
                        title: AppLocalizations.of(context)!.register,
                        subtitle:
                            AppLocalizations.of(context)!.firstTimeSubtitle,
                        isPrimary: false,
                        onTap: () => context.go('/register/step1'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Decree badge ──────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.goldAccent.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: AppColors.goldAccent,
                      ),
                      SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.decree2181Compliance,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.goldAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthOptionCard extends StatelessWidget {
  const _AuthOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary ? AppColors.primaryGreen : context.colors.surface;
    final fgColor = isPrimary ? Colors.white : context.colors.darkText;
    final subColor =
        isPrimary ? Colors.white.withAlpha(180) : context.colors.slate500;
    final borderColor =
        isPrimary ? Colors.transparent : context.colors.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow:
                isPrimary
                    ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isPrimary
                          ? Colors.white.withAlpha(30)
                          : AppColors.primaryGreen.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fgColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: subColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: fgColor.withAlpha(180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
