import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/core/providers/service_providers.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/controllers/auth_controller.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(userProfileProvider);
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.dashboard, '/ai/dashboard'),
      (Icons.account_balance_wallet_rounded, l10n.surplus, '/ai/surplus'),
      (Icons.archive_outlined, l10n.policies, '/ai/policies'),
      (Icons.receipt_long_outlined, l10n.claims, '/ai/claims'),
      (Icons.local_offer_outlined, l10n.manageOffers, '/ai/offers'),
      (Icons.settings_outlined, l10n.settings, '/ai/settings'),
    ];

    void showComingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.featureComingSoon,
            style: GoogleFonts.ibmPlexSansArabic(),
          ),
          backgroundColor: colors.goldAccent,
        ),
      );
    }

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: PortalLayout(
        selectedIndex: 5,
        portalTitle: l10n.aiPortalTitle,
        portalSubtitle: l10n.settings,
        accentColor: colors.goldAccent,
        appBarColor: colors.beigeBg,
        appBarTextColor: colors.goldAccent,
        selectedItemColor: colors.goldAccent,
        selectedItemBgColor: colors.beigeCard,
        unselectedItemColor: colors.premiumSubtext,
        sidebarBgColor: colors.beigeBg,
        menuItems: menuItems,
        body: PageEntryAnimation(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSection(context, userAsync, showComingSoon, l10n),
                              const SizedBox(height: 24),
                              _buildSettingsGroup(context, l10n.preferences, [
                                _SettingsTile(
                                  icon: Icons.language_rounded,
                                  title: l10n.language,
                                  trailing: const LanguagePickerButton(),
                                  onTap: showComingSoon,
                                ),
                                Divider(color: colors.warmDivider, height: 1, indent: 48, endIndent: 16),
                                _SettingsTile(
                                  icon: Icons.dark_mode_outlined,
                                  title: l10n.nightMode,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colors.goldAccent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Coming Soon',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: colors.goldAccent.withValues(alpha: 0.6),
                                            fontFamily: 'Cairo',
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: false,
                                        onChanged: null,
                                        activeColor: colors.goldAccent,
                                        inactiveTrackColor: colors.beigeCard,
                                        inactiveThumbColor: colors.premiumSubtext.withValues(alpha: 0.4),
                                      ),
                                    ],
                                  ),
                                  onTap: (){},
                                ),
                              ]),
                              const SizedBox(height: 24),
                              _buildSettingsGroup(context, l10n.support, [
                                _SettingsTile(
                                  icon: Icons.help_outline_rounded,
                                  title: l10n.helpCenter,
                                  onTap: showComingSoon,
                                ),
                                Divider(color: colors.warmDivider, height: 1, indent: 48, endIndent: 16),
                                _SettingsTile(
                                  icon: Icons.info_outline_rounded,
                                  title: l10n.aboutApp,
                                  onTap: showComingSoon,
                                ),
                              ]),
                              const SizedBox(height: 40),
                              Center(
                                child: SizedBox(
                                  width: 220,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await ref.read(authControllerProvider.notifier).signOut();
                                      if (context.mounted) context.go(AppRoutes.roleSelection);
                                    },
                                    icon: Icon(Icons.logout_rounded, color: colors.error),
                                    label: Text(
                                      l10n.logout,
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        color: colors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: colors.error, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(kRadiusSm),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const AppFooter(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          onTap: (idx) {
            if (idx == 0) context.go('/ai/dashboard');
            if (idx == 1) context.go('/ai/surplus');
            if (idx == 2) context.go('/ai/policies');
            if (idx == 3) context.go('/ai/settings');
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colors.goldAccent,
          unselectedItemColor: colors.premiumSubtext,
          backgroundColor: colors.beigeBg,
          selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.dashboard),
            BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_rounded), label: l10n.surplus),
            BottomNavigationBarItem(icon: const Icon(Icons.archive_outlined), label: l10n.policies),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: l10n.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AsyncValue<Map<String, dynamic>?> userAsync, VoidCallback onEdit, AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: colors.warmDivider),
        boxShadow: [
          BoxShadow(
            color: colors.goldAccent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: userAsync.when(
        data: (user) {
          final name = user?['full_name'] as String? ?? l10n.systemOperator;
          final email = Supabase.instance.client.auth.currentUser?.email ?? 'operator@alittihad.dz';
          return Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colors.goldAccent,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'م',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.beigeBg,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.premiumText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12,
                        color: colors.premiumSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: colors.goldAccent),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: colors.goldAccent)),
        error: (err, _) => Text(l10n.errorGeneric(err.toString()), style: GoogleFonts.ibmPlexSansArabic(color: colors.error)),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.amiri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.goldAccent,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.beigeCard,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: colors.warmDivider),
            boxShadow: [
              BoxShadow(
                color: colors.goldAccent.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      leading: Icon(icon, color: colors.goldAccent),
      title: Text(
        title,
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.premiumText,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: colors.goldAccent),
      onTap: onTap,
    );
  }
}