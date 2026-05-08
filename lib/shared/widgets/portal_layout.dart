import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/features/shared/widgets/app_sidebar.dart';
import 'package:tameenidz/shared/widgets/responsive_layout.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/shared/widgets/language_dropdown.dart';

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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: isMobile ? bottomNavigationBar : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(context)) : null,
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
                              context.go('/');
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
                if (appBarActions != null) ...appBarActions!,
                const LanguageDropdown(),
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
                  context.go('/');
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
          const LanguageDropdown(),
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
    );
  }
}
