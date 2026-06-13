import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/providers/service_providers.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/core/controllers/auth_controller.dart';

class ClientSettingsScreen extends ConsumerWidget {
  const ClientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final user = Supabase.instance.client.auth.currentUser;

    final role = user?.userMetadata?['role'] as String? ?? 'client';
    final isAT =
        user?.userMetadata?['operator_id']?.toString().contains('at') ?? true;
    final List<(IconData, String, String)> menuItems;
    if (role == 'admin') {
      menuItems = [
        (Icons.dashboard_rounded, l10n.dashboard, '/admin/dashboard'),
        (Icons.auto_graph_rounded, l10n.commissionsAdmin, '/admin/commission'),
        (Icons.history_edu_rounded, l10n.legalRecord, '/admin/audit'),
        (Icons.manage_accounts_rounded, l10n.userManagement, '/admin/users'),
        (Icons.settings_rounded, l10n.settingsAdmin, '/admin/settings'),
      ];
    } else if (role == 'employee' || role == 'operator') {
      menuItems = [
        (
        Icons.dashboard_rounded,
        l10n.dashboard,
        isAT ? '/at/dashboard' : '/ai/dashboard',
        ),
        (
        Icons.history_edu_rounded,
        l10n.surplus,
        isAT ? '/at/surplus' : '/ai/surplus',
        ),
        (
        Icons.settings_rounded,
        l10n.settings,
        isAT ? '/at/settings' : '/ai/settings',
        ),
      ];
    } else {
      menuItems = [
        (Icons.dashboard_rounded, l10n.homeNav, '/client'),
        (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
        (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
        (Icons.headset_mic_rounded, l10n.support, '/client/support'),
        (Icons.settings_rounded, l10n.settings, '/client/settings'),
      ];
    }

    final selectedIndex = menuItems.indexWhere(
          (item) =>
      item.$3 == '/client/settings' ||
          item.$3 == '/admin/settings' ||
          item.$3 == '/at/settings' ||
          item.$3 == '/ai/settings',
    );

    final companyName = isAT ? l10n.algeriaTakaful : l10n.alIttihad;

    return PortalLayout(
      selectedIndex: selectedIndex,
      menuItems: menuItems,
      portalTitle:
      (role == 'employee' || role == 'operator')
          ? companyName
          : l10n.settings,
      portalSubtitle:
      (role == 'employee' || role == 'operator')
          ? l10n.settings
          : l10n.shariaInsurance,
      topHeader: (role == 'employee' || role == 'operator') ? 'PORTAL' : null,
      accentColor:
      (role == 'employee' || role == 'operator')
          ? (isAT ? AppColors.primaryGreen : AppColors.alIttihadGreen)
          : colors.primary,
      showBackButton: true,
      fallbackRoute:
      role == 'admin'
          ? '/admin/dashboard'
          : (role == 'employee' || role == 'operator')
          ? (isAT ? '/at/dashboard' : '/ai/dashboard')
          : '/client',
      body: PageEntryAnimation(child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildProfileCard(context, ref, user, role),
            const SizedBox(height: 32),
            _buildSectionHeader(context, l10n.preferences),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(l10n.language),
                    trailing: const LanguageDropdown(),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colors.outlineVariant.withValues(alpha: 0.1),
                  ),
                  SwitchListTile(
                    value: false,
                    onChanged: null,
                    secondary: Icon(Icons.dark_mode_outlined, color: Colors.grey.withValues(alpha: 0.4)),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(l10n.darkMode, style: TextStyle(color: Colors.grey.withValues(alpha: 0.4)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.withValues(alpha: 0.6),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48),
            _buildLogoutButton(context, ref, l10n),
          ]),
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context,
      WidgetRef ref,
      User? user,
      String role,
      ) {
    final userAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final email = user?.email ?? '---';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person_rounded, size: 40, color: colors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: userAsync.when(
              data: (profile) {
                String defaultName = l10n.clientRoleLabel;
                if (role == 'admin') defaultName = l10n.adminRoleLabel;
                if (role == 'employee' || role == 'operator') {
                  defaultName = l10n.operatorRoleLabel;
                }

                final name =
                    user?.userMetadata?['full_name'] ??
                        profile?['full_name'] ??
                        defaultName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.userMetadata?['full_name'] ?? email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: context.colors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await ref.read(authControllerProvider.notifier).signOut();
          if (context.mounted) context.go('/');
        },
        icon: Icon(Icons.logout_rounded, color: colors.error),
        label: Text(
          l10n.logout,
          style: TextStyle(color: colors.error, fontWeight: FontWeight.w800),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colors.error.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}