import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/constants/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/shared/widgets/responsive_layout.dart';

class OperatorAuthGateScreen extends StatelessWidget {
  const OperatorAuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // ── Decorative Background ──────────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.subscriberFund.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: ResponsiveWidthConstraint(
              child: CustomScrollView(
                slivers: [
                  // ── App Bar ─────────────────────────────────────────
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
                      onPressed: () => context.go('/role'),
                    ),
                    centerTitle: true,
                    title: Text(
                      l10n.operatorPortal,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // ── Content ─────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          l10n.chooseCompanyPrompt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ── Algeria Takaful Card ────────────────────────
                        _CompanyAuthCard(
                          name: l10n.algeriaTakaful,
                          color: AppColors.primaryGreen,
                          icon: Icons.shield_rounded,
                          onLogin: () => context.go('/at/login'),
                          onRegister: () => context.go('/at/register'),
                        ),
                        const SizedBox(height: 24),

                        // ── Al-Ittihad Card ─────────────────────────────
                        _CompanyAuthCard(
                          name: l10n.alIttihad,
                          color: AppColors.alIttihadGreen,
                          icon: Icons.verified_user_rounded,
                          onLogin: () => context.go('/ai/login'),
                          onRegister: () => context.go('/ai/register'),
                        ),
                        
                        const SizedBox(height: 64),
                        // ── Support Info ───────────────────────────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.help_outline_rounded, color: colors.primary, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.needHelp,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors.onSurface,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        l10n.contactSupportTeam,
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
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
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyAuthCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _CompanyAuthCard({
    required this.name,
    required this.color,
    required this.icon,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Upper Part: Branding
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lower Part: Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                // Register
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRegister,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color.withValues(alpha: 0.5)),
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: Text(
                      l10n.registerAction,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Login
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: Text(
                      l10n.loginAction,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
