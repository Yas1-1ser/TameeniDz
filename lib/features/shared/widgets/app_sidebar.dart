import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/service_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AppSidebar extends ConsumerWidget {
  final int selectedIndex;
  final List<(IconData, String, String)> menuItems;
  final String portalTitle;
  final String portalSubtitle;
  final Color accentColor;
  final String? topHeader;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.menuItems,
    required this.portalTitle,
    required this.portalSubtitle,
    required this.accentColor,
    this.topHeader,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Container(
      width: 280, // Slightly wider for better legibility
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // ── Header Profile ──────────────────────────────────
          _buildProfileHeader(context, userAsync, l10n),

          const SizedBox(height: 12),
          const Divider(indent: 20, endIndent: 20, height: 1),
          const SizedBox(height: 12),

          // ── Menu Items ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final active = selectedIndex == index;
                return _SidebarItem(
                  icon: item.$1,
                  label: item.$2,
                  route: item.$3,
                  isActive: active,
                  accentColor: accentColor,
                );
              },
            ),
          ),

          // ── Footer ─────────────────────────────────────────
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
                Icon(Icons.menu_rounded, size: 20, color: context.colors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  topHeader!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: context.colors.onSurfaceVariant,
                    letterSpacing: 1.2,
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
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: userAsync.when(
                  data: (user) {
                    final name = user?['full_name'] as String? ?? 'AU';
                    final initials = name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();
                    return Text(
                      initials.isEmpty ? 'AU' : initials,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    );
                  },
                  loading: () => Icon(Icons.person_outline, color: accentColor, size: 28),
                  error: (_, __) => Icon(Icons.person_outline, color: accentColor, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portalTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.colors.onSurface,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        portalSubtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
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
            color: context.colors.outlineVariant.withValues(alpha: 0.2),
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
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Switch.adaptive(
                value: isDark,
                activeColor: accentColor,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
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
            onTap: () async {
              await ref.read(supabaseClientProvider).auth.signOut();
              if (context.mounted) context.go('/onboarding');
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

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.accentColor,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : (isDestructive ? AppColors.rejected : context.colors.onSurfaceVariant);
    
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
              color: isActive ? accentColor.withValues(alpha: 0.1) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon, 
                  size: 20, 
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: color,
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
