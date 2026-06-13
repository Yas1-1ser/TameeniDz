import 'package:supabase_flutter/supabase_flutter.dart';
import '../router/app_routes.dart';

class SessionGuard {
  SessionGuard._();

  static String operatorRouteFromCompany(String? company) {
    switch (company?.toLowerCase()) {
      case 'al_ittihad':
        return AppRoutes.ittihadDashboard;
      case 'algeria_takaful':
      default:
        return AppRoutes.takafulDashboard;
    }
  }

  static String routeForRole({required String role, String? company}) {
    final normalized = role.toLowerCase();
    if (normalized == 'admin') return AppRoutes.adminDashboard;
    if (normalized == 'operator' || normalized == 'employee') {
      return operatorRouteFromCompany(company);
    }
    return AppRoutes.home;
  }

  static Future<String> resolveRouteForCurrentUser({
    SupabaseClient? client,
  }) async {
    final supabase = client ?? Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return AppRoutes.roleSelection;

    try {
      final profile =
          await supabase
              .from('users')
              .select('role, company')
              .eq('id', user.id)
              .maybeSingle();

      final role = (profile?['role'] as String?) ?? 'client';
      final company = profile?['company'] as String?;
      return routeForRole(role: role, company: company);
    } on PostgrestException {
      return AppRoutes.home;
    } catch (_) {
      return AppRoutes.home;
    }
  }
}
