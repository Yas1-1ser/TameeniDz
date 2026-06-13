import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/features/shared/widgets/app_sidebar.dart';
import 'package:tameenidz/features/shared/widgets/responsive_layout.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/providers/notification_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class PortalLayout extends ConsumerWidget {
  final Widget body;
  final int selectedIndex;
  final List<(IconData, String, String)> menuItems;
  final String portalTitle;
  final String portalSubtitle;
  final Color accentColor;
  final List<Widget>? appBarActions;
  final bool showBackButton;
  final Widget? bottomNavigationBar;
  final String? topHeader;
  final Color? appBarColor;
  final Color? appBarTextColor;

  final String? fallbackRoute;

  // Custom styling overrides for premium templates
  final Color? selectedItemColor;
  final Color? selectedItemBgColor;
  final Color? unselectedItemColor;
  final Color? sidebarBgColor;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const PortalLayout({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.menuItems,
    required this.portalTitle,
    required this.portalSubtitle,
    required this.accentColor,
    this.appBarActions,
    this.showBackButton = false,
    this.bottomNavigationBar,
    this.topHeader,
    this.appBarColor,
    this.appBarTextColor,
    this.fallbackRoute,
    this.selectedItemColor,
    this.selectedItemBgColor,
    this.unselectedItemColor,
    this.sidebarBgColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: colors.beigeBg,
      bottomNavigationBar: isMobile ? bottomNavigationBar : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(context)) : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      appBar: isMobile
          ? AppBar(
              backgroundColor: appBarColor ?? colors.surfaceContainerLowest,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: appBarTextColor ?? accentColor),
              leadingWidth: showBackButton ? 96 : 56,
              leading: Container(
                margin: const EdgeInsetsDirectional.only(start: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showBackButton)
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 22),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else if (fallbackRoute != null) {
                              context.go(fallbackRoute!);
                            } else {
                              context.go(AppRoutes.splash); // FIXED: hardcoded '/'
                            }
                          },
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(36, 36),
                            backgroundColor: accentColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    if (showBackButton) const SizedBox(width: 4),
                    Builder(
                      builder: (context) => SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(36, 36),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                portalTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appBarTextColor ?? colors.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 16, // Slightly smaller for better fit
                ),
              ),
              actions: [
                _PortalNotificationButton(color: appBarTextColor ?? accentColor),
                if (appBarActions != null) ...appBarActions!,
                const LanguagePickerButton(),
                const SizedBox(width: 4),
              ],
            )
          : null,
      body: ResponsiveLayout(
        mobile: body,
        desktop: Row(
          children: [
            _buildSidebar(context),
            Expanded(
              child: Column(
                children: [
                  if (!isMobile) _buildDesktopTopBar(context),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else if (fallbackRoute != null) {
                  context.go(fallbackRoute!);
                } else {
                  context.go(AppRoutes.splash); // FIXED: hardcoded '/'
                }
              },
              icon: Icon(Icons.arrow_back_rounded, size: 18, color: accentColor),
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 24),
          ],
          Text(
            portalTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          _PortalNotificationButton(color: accentColor),
          const SizedBox(width: 16),
          const LanguagePickerButton(),
          if (appBarActions != null) ...[
            const SizedBox(width: 16),
            ...appBarActions!,
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AppSidebar(
      selectedIndex: selectedIndex,
      menuItems: menuItems,
      portalTitle: portalTitle,
      portalSubtitle: portalSubtitle,
      accentColor: accentColor,
      topHeader: topHeader,
      selectedItemColor: selectedItemColor,
      selectedItemBgColor: selectedItemBgColor,
      unselectedItemColor: unselectedItemColor,
      sidebarBgColor: sidebarBgColor,
    );
  }
}

class _PortalNotificationButton extends ConsumerWidget {
  final Color color;
  const _PortalNotificationButton({required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    return IconButton(
      tooltip: AppLocalizations.of(context)!.notifications,
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        backgroundColor: const Color(0xFFE53935), // Red
        label: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
        child: Icon(
          Icons.notifications_outlined,
          color: color,
        ),
      ),
      onPressed: () {
        context.push(AppRoutes.notifications);
      },
    );
  }
}
