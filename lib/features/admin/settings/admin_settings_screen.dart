import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/core/controllers/auth_controller.dart';
import 'package:tameenidz/features/shared/data/user_repository.dart';
import 'package:tameenidz/core/providers/theme_provider.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  void _showResetSystemDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error),
            const SizedBox(width: 8),
            Text(l10n.adminRoleLabel, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          l10n.adminResetSystemConfirm,
          style: TextStyle(fontFamily: 'Cairo', height: 1.5, color: colors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _performSystemReset(context, ref, l10n);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error, foregroundColor: Colors.white),
            child: Text(l10n.adminWipeAll, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _performSystemReset(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final colors = context.colors;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: colors.primary)),
    );

    try {
      await ref.read(userRepositoryProvider).wipeSystemData();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminResetSystemSuccess), backgroundColor: colors.primary),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: colors.premiumText,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.premiumText),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        actions: const [LanguagePickerButton(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: adminBottomNav(context, 5, l10n),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context, user, l10n),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, l10n.preferences, [
              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: colors.goldAccent.withValues(alpha: 0.4),
                ),
                title: Row(
                  children: [
                    Text(
                      l10n.darkMode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.premiumText.withValues(alpha: 0.4),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.goldAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.comingSoon,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.goldAccent.withValues(alpha: 0.6),
                          fontFamily: 'Cairo',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                activeColor: colors.goldAccent,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, l10n.systemSettings, [
              _buildSettingsTile(
                context,
                Icons.security_outlined,
                l10n.securityConfiguration,
              ),
              _buildSettingsTile(
                context,
                Icons.notifications_outlined,
                l10n.systemNotifications,
              ),
              _buildSettingsTile(context, Icons.backup_outlined, l10n.dataBackup),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, l10n.userPermissions, [
              _buildSettingsTile(
                context,
                Icons.admin_panel_settings_outlined,
                l10n.roleManagement,
              ),
              _buildSettingsTile(
                context,
                Icons.list_alt_outlined,
                l10n.activityLogs,
                onTap: () => context.go(AppRoutes.adminAudit),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, l10n.adminDangerZone, [
              _buildSettingsTile(
                context,
                Icons.delete_forever_outlined,
                l10n.adminResetSystemTitle,
                onTap: () => _showResetSystemDialog(context, ref, l10n),
                isDestructive: true,
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.roleSelection);
                },
                icon: const Icon(Icons.logout_outlined, size: 20),
                label: Text(
                  l10n.logout,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.premiumHeroBg,
                  foregroundColor: colors.premiumGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      BuildContext context,
      User? user,
      AppLocalizations l10n,
      ) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.premiumBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.beigeBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: colors.premiumGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminRole,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.premiumText,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.premiumSubtext,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
      BuildContext context,
      String title,
      List<Widget> children,
      ) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colors.premiumSubtext,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.premiumBorder, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
      BuildContext context,
      IconData icon,
      String title, {
        VoidCallback? onTap,
        bool isDestructive = false,
      }) {
    final colors = context.colors;
    return ListTile(
      onTap: onTap ?? () {},
      leading: Icon(icon, color: isDestructive ? colors.error : colors.goldAccent, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDestructive ? colors.error : colors.premiumText,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: colors.premiumSubtext,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}