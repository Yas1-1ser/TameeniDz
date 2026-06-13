import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  
  const AdminShell({super.key, required this.child});

  static int calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.adminCommission)) return 1;
    if (location.startsWith(AppRoutes.adminAudit)) return 2;
    if (location.startsWith(AppRoutes.adminUsers)) return 3;
    if (location.startsWith(AppRoutes.adminWallet)) return 4;
    if (location.startsWith(AppRoutes.adminSettings)) return 5;
    return 0;
  }

  static void onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.adminDashboard);
        break;
      case 1:
        context.go(AppRoutes.adminCommission);
        break;
      case 2:
        context.go(AppRoutes.adminAudit);
        break;
      case 3:
        context.go(AppRoutes.adminUsers);
        break;
      case 4:
        context.go(AppRoutes.adminWallet);
        break;
      case 5:
        context.go(AppRoutes.adminSettings);
        break;
    }
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: context.colors.offWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.appName, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.darkText)),
        content: Text(AppLocalizations.of(context)!.exitConfirmMessage, style: TextStyle(color: context.colors.slate500)),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: context.colors.slate500))),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(AppLocalizations.of(context)!.exit, style: const TextStyle(color: AppColors.rejected))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = calculateSelectedIndex(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context) ?? false;
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.beigeBg,
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: context.colors.beigeCard,
          selectedItemColor: AppColors.goldAccent,
          unselectedItemColor: const Color(0xFF6B6B6B),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: (index) => onItemTapped(index, context),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_graph_outlined),
              activeIcon: const Icon(Icons.auto_graph),
              label: l10n.commissionsAdmin,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_edu_outlined),
              activeIcon: const Icon(Icons.history_edu),
              label: l10n.legalRecord,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.manage_accounts_outlined),
              activeIcon: const Icon(Icons.manage_accounts),
              label: l10n.userManagement,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: l10n.wallet,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settingsAdmin,
            ),
          ],
        ),
      ),
    );
  }
}
