import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/router/route_guards.dart';
import 'package:tameenidz/core/constants/role_constants.dart';

/// Reads the authenticated user's role from `public.users`
/// and navigates to the correct dashboard.
///
/// Usage (after successful login):
/// ```dart
/// await RoleRouter.routeByRole(context);
/// ```
class RoleRouter {
  RoleRouter._();

  /// Maps a DB role string → the correct dashboard route.
  static String dashboardRouteForRole(String role, {String? operatorCode}) {
    // Standardize role name for compatibility
    final normalizedRole = role.toLowerCase().trim();
    String authRole = RoleConstants.subscriber;
    if (normalizedRole == 'admin') authRole = RoleConstants.admin;
    if (normalizedRole == 'operator') authRole = RoleConstants.operator;

    // Delegates directly to the single source of truth: RouteGuards.roleRoot
    return RouteGuards.roleRoot(authRole, operatorCode ?? '');
  }

  /// Fetches role (and operator company) from DB, then navigates.
  /// Safe to call from any widget with a valid BuildContext.
  static Future<void> routeByRole(BuildContext context) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      if (context.mounted) context.go(AppRoutes.roleSelection);
      return;
    }

    try {
      final profile = await Supabase.instance.client
          .from('users')
          .select('role, company')
          .eq('id', uid)
          .maybeSingle();

      if (!context.mounted) return;

      if (profile == null) {
        context.go(AppRoutes.roleSelection);
        return;
      }

      final role    = (profile['role'] as String?)?.toLowerCase().trim() ?? 'client';
      final company = (profile['company'] as String?)?.toLowerCase().trim() ?? '';

      // Normalize company to operator code
      String opCode = '';
      if (company == 'al_ittihad') opCode = 'ITTIHAD';
      if (company == 'algeria_takaful') opCode = 'TAKAFUL';

      context.go(dashboardRouteForRole(role, operatorCode: opCode));
    } catch (_) {
      if (context.mounted) context.go(AppRoutes.roleSelection);
    }
  }
}
