import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/service_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/controllers/auth_controller.dart';
import 'package:tameenidz/core/constants/role_constants.dart';

/// Redesigned premium Tameeni Elite Sidebar.
/// Features a luxury beige deep surface, gold dividers, and active item indicators.
class AppSidebar extends ConsumerWidget {
  final int selectedIndex;
  final List<(IconData, String, String)> menuItems;
  final String portalTitle;
  final String portalSubtitle;
  final Color accentColor;
  final String? topHeader;

  // Custom premium styling overrides
  final Color? selectedItemColor;
  final Color? selectedItemBgColor;
  final Color? unselectedItemColor;
  final Color? sidebarBgColor;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.menuItems,
    required this.portalTitle,
    required this.portalSubtitle,
    required this.accentColor,
    this.topHeader,
    this.selectedItemColor,
    this.selectedItemBgColor,
    this.unselectedItemColor,
    this.sidebarBgColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    final authState = ref.watch(authControllerProvider);
    final role = authState.userRole;
    final operatorCode = authState.operatorCode;

    final filteredItems =
        menuItems.where((item) {
          final route = item.$3;
          if (route.isEmpty) return true;

          // 1. If it's an admin route, only admins can see it
          if (route == '/admin' || route.startsWith('/admin/')) {
            return role == RoleConstants.admin;
          }

          // 2. If it's an Algeria Takaful operator route, only Takaful operators can see it
          if (route == '/at' || route.startsWith('/at/')) {
            return role == RoleConstants.operator &&
                operatorCode == RoleConstants.companyTakaful;
          }

          // 3. If it's an Al-Ittihad operator route, only Ittihad operators can see it
          if (route == '/ai' || route.startsWith('/ai/')) {
            return role == RoleConstants.operator &&
                operatorCode == RoleConstants.companyIttihad;
          }

          // 4. If it's a general operator route, only operators can see it
          if (route == '/operator' || route.startsWith('/operator/')) {
            return role == RoleConstants.operator;
          }

          // 5. If it's a client/subscriber route, only subscribers or admins can see it
          if (route.startsWith('/client/') ||
              route == '/client' ||
              route == '/subscriber') {
            return role == RoleConstants.subscriber ||
                role == RoleConstants.admin;
          }

          return true;
        }).toList();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: sidebarBgColor ?? context.colors.beigeDeep,
        border: Border(
          right: BorderSide(
            color: AppColors.goldAccent.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Profile
          _buildProfileHeader(context, userAsync, l10n),

          const SizedBox(height: 12),
          Divider(
            color: AppColors.goldAccent.withValues(alpha: 0.20),
            indent: 20,
            endIndent: 20,
            height: 1,
          ),
          const SizedBox(height: 12),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final originalIndex = menuItems.indexOf(item);
                final active = selectedIndex == originalIndex;
                return _SidebarItem(
                  icon: item.$1,
                  label: item.$2,
                  route: item.$3,
                  isActive: active,
                  accentColor: accentColor,
                  selectedItemColor: selectedItemColor,
                  selectedItemBgColor: selectedItemBgColor,
                  unselectedItemColor: unselectedItemColor,
                );
              },
            ),
          ),

          // Footer
          _buildFooter(context, ref, isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?> userAsync,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topHeader != null ? 40 : 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topHeader != null) ...[
            Row(
              children: [
                Icon(
                  Icons.menu_rounded,
                  size: 20,
                  color: context.colors.slate500,
                ),
                SizedBox(width: 8),
                Text(
                  topHeader!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: context.colors.slate500,
                    letterSpacing: 1.2,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: userAsync.when(
                  data: (user) {
                    final name = user?['full_name'] as String? ?? 'AU';
                    final initials =
                        name
                            .split(' ')
                            .take(2)
                            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                            .join();
                    return Text(
                      initials.isEmpty ? 'AU' : initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        fontFamily: 'Cairo',
                      ),
                    );
                  },
                  loading:
                      () => const Icon(
                        Icons.person_outline,
                        color: AppColors.primaryGreen,
                        size: 28,
                      ),
                  error:
                      (_, __) => const Icon(
                        Icons.person_outline,
                        color: AppColors.primaryGreen,
                        size: 28,
                      ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portalTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.colors.darkText,
                        letterSpacing: -0.5,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        portalSubtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.goldAccent.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.darkMode,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.slate500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              Switch.adaptive(
                value: isDark,
                activeColor: AppColors.goldAccent,
                activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.3),
                onChanged:
                    (_) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SidebarItem(
            icon: Icons.logout,
            label: l10n.logout,
            route: '',
            isActive: false,
            accentColor: AppColors.rejected,
            isDestructive: true,
            selectedItemColor: selectedItemColor,
            selectedItemBgColor: selectedItemBgColor,
            unselectedItemColor: unselectedItemColor,
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted)
                context.go(AppRoutes.onboarding); // FIXED: hardcoded route
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final Color accentColor;
  final bool isDestructive;
  final VoidCallback? onTap;

  final Color? selectedItemColor;
  final Color? selectedItemBgColor;
  final Color? unselectedItemColor;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.accentColor,
    this.isDestructive = false,
    this.onTap,
    this.selectedItemColor,
    this.selectedItemBgColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedItemColor ?? AppColors.primaryGreen;
    final unactiveColor =
        isDestructive
            ? AppColors.rejected
            : (unselectedItemColor ?? context.colors.slate500);
    final color = isActive ? activeColor : unactiveColor;
    final activeBg =
        selectedItemBgColor ?? AppColors.primaryGreen.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.go(route),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? activeBg : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 3,
                    height: 20,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                      fontFamily: 'Cairo',
                      letterSpacing: isActive ? -0.2 : 0,
                    ),
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
