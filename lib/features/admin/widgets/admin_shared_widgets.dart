import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/providers/notification_providers.dart';

// ── Admin Notification Button ────────────────────────────────────────────────
class AdminNotificationButton extends ConsumerWidget {
  const AdminNotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    return IconButton(
      tooltip: AppLocalizations.of(context)?.notifications ?? 'Notifications',
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        backgroundColor: const Color(0xFFE53935), // Red
        label: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
        child: const Icon(
          Icons.notifications_outlined,
          color: Color(0xFFC9A96E),
        ),
      ),
      onPressed: () => context.push(AppRoutes.adminNotifications),
    );
  }
}

// ── Top AppBar ─────────────────────────────────────────────────────────────
PreferredSizeWidget buildAdminAppBar(BuildContext context, String title, {List<Widget>? actions, bool showBackButton = true}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return AppBar(
    backgroundColor: const Color(0xFF2D1F0E),
    elevation: 0,
    automaticallyImplyLeading: false,
    leading: showBackButton ? IconButton(
      icon: Icon(
        isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
        color: const Color(0xFFC9A96E),
        size: 20,
      ),
      onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.adminDashboard),
    ) : null,
    title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo')),
    actions: [
      const AdminNotificationButton(),
      if (actions != null) ...actions,
    ],
  );
}

// ── Section Label ───────────────────────────────────────────────────────────
Widget adminSectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 12, top: 4),
  child: Row(children: [
    Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFC9A96E), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2D1F0E), fontFamily: 'Cairo')),
  ]),
);

// ── White Card ──────────────────────────────────────────────────────────────
Widget adminCard(BuildContext context, {required Widget child, EdgeInsets? padding}) => Container(
  padding: padding ?? const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
  ),
  child: child,
);

// ── Status Badge ────────────────────────────────────────────────────────────
Widget statusBadge(String label, {required Color bg, required Color fg}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
  child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg, fontFamily: 'Cairo')),
);

// ── Gold Primary Button ─────────────────────────────────────────────────────
Widget goldButton(String label, VoidCallback onTap, {bool loading = false}) => GestureDetector(
  onTap: loading ? null : onTap,
  child: Container(
    height: 52, width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFF2D1F0E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFC9A96E), width: 1),
    ),
    alignment: Alignment.center,
    child: loading
      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFC9A96E), strokeWidth: 2))
      : Text(label, style: const TextStyle(color: Color(0xFFC9A96E), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
  ),
);

// ── Premium Text Field ──────────────────────────────────────────────────────
InputDecoration adminFieldDecoration(BuildContext context, String label, IconData icon) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Color(0xFF8B7355), fontSize: 13, fontFamily: 'Cairo'),
  prefixIcon: Icon(icon, color: const Color(0xFFC9A96E), size: 20),
  filled: true,
  fillColor: context.colors.surface,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5DDD0))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5DDD0))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC9A96E), width: 1.5)),
);

// ── Bottom Navigation Bar ───────────────────────────────────────────────────
BottomNavigationBar adminBottomNav(BuildContext context, int currentIndex, AppLocalizations l10n) {
  final routes = [
    AppRoutes.adminDashboard,
    AppRoutes.adminCommission,
    AppRoutes.adminAudit,
    AppRoutes.adminUsers,
    AppRoutes.adminWallet,
    AppRoutes.adminSettings,
  ];
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (i) => context.go(routes[i]),
    backgroundColor: const Color(0xFF2D1F0E),
    selectedItemColor: const Color(0xFFC9A96E),
    unselectedItemColor: const Color(0xFFC9A96E).withValues(alpha: 0.4),
    selectedLabelStyle: const TextStyle(fontSize: 9, fontFamily: 'Cairo'),
    unselectedLabelStyle: const TextStyle(fontSize: 9, fontFamily: 'Cairo'),
    type: BottomNavigationBarType.fixed,
    items: [
      BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), label: l10n.dashboard),
      BottomNavigationBarItem(icon: const Icon(Icons.percent), label: l10n.commissionsAdmin),
      BottomNavigationBarItem(icon: const Icon(Icons.gavel_outlined), label: l10n.legalRecord),
      BottomNavigationBarItem(icon: const Icon(Icons.manage_accounts_outlined), label: l10n.userManagement),
      BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), label: l10n.totalWallet),
      BottomNavigationBarItem(icon: const Icon(Icons.settings_outlined), label: l10n.settingsAdmin),
    ],
  );
}
