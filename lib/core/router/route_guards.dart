// lib/core/router/route_guards.dart

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/constants/role_constants.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

class RouteGuards {
  RouteGuards._();

  // ─── Route sets ─────────────────────────────────────────────────────────────

  /// Exact routes that are always accessible — branding, onboarding, static,
  /// and operator info pages visible to all users (guests included).
  /// NOTE: Do NOT put parametrized route templates (e.g. '/client/plans/:planId')
  /// here — exact Set.contains() will never match a real path with an ID.
  /// Use [_isPublicPath] for pattern-based matching instead.
  static const _publicRoutes = {
    AppRoutes.splash,        // '/'
    AppRoutes.onboarding,    // '/onboarding'
    AppRoutes.welcome,       // '/welcome'
    AppRoutes.roleSelection, // '/role'
    AppRoutes.roleClient,
    AppRoutes.roleOperator,
    AppRoutes.about,
    AppRoutes.privacyPolicy,
    AppRoutes.termsAndConditions,
    AppRoutes.howTakafulWorks,
    AppRoutes.legalFramework,
    AppRoutes.faq,
    AppRoutes.contactUs,
    AppRoutes.clientOperatorIttihad,
    AppRoutes.clientOperatorTakaful,
    AppRoutes.plans,
    AppRoutes.sos,

    AppRoutes.roadsideAssist,
    AppRoutes.registerStep1,
    AppRoutes.registerStep2,
    AppRoutes.registerStep3, // Allow Step 3 during registration flow
    AppRoutes.otpVerify,     // FIX: Allow OTP verification to complete without dashboard redirect
  };

  /// Returns true if [path] is publicly accessible, including parametrized
  /// routes (e.g. '/client/plans/some-id') that cannot be matched by a Set.
  static bool _isPublicPath(String path) {
    if (_publicRoutes.contains(path)) return true;
    // planDetail: '/client/plans/:planId' — match any concrete plan path
    if (path.startsWith('/client/plans/')) return true;
    return false;
  }

  /// Pure auth screens that logged-in users should be redirected AWAY from.
  static const _authOnlyRoutes = {
    AppRoutes.clientLogin,
    AppRoutes.clientPhoneLogin,
    AppRoutes.forgotPassword,
    AppRoutes.operatorRegister,
    AppRoutes.atLogin,
    AppRoutes.atRegister,
    AppRoutes.aiLogin,
    AppRoutes.aiRegister,
    AppRoutes.adminLogin,
    AppRoutes.adminRegister,
  };

  // ─── Main guard ─────────────────────────────────────────────────────────────

  static String? authGuard(BuildContext context, GoRouterState state) {
    final auth = AuthService.instance;
    final path = state.matchedLocation;

    // FIX #8: If auth is not initialized yet, allow any public route to proceed,
    // otherwise redirect to splash screen during the initialization phase.
    if (!auth.isInitialized) {
      return _isPublicPath(path) ? null : AppRoutes.splash;
    }

    final isLoggedIn = auth.isLoggedIn;
    final role = auth.userRole;

    final isPublic = _isPublicPath(path);
    final isAuthOnly = _authOnlyRoutes.contains(path);

    // 1. Guest trying to access a private dashboard route → redirect to login
    if (!isLoggedIn && !isPublic && !isAuthOnly) {
      return _loginRouteFor(path);
    }

    // 2. Logged-in user trying to access a pure Auth page or role/operator selection page → redirect to dashboard.
    if (isLoggedIn && (isAuthOnly || path == AppRoutes.roleSelection || path == AppRoutes.operatorSelection)) {
      if (path == AppRoutes.operatorSelection && role == RoleConstants.operator && auth.operatorCode.isEmpty) {
        return null;
      }
      if (path == AppRoutes.atLogin && _matchesOperatorCompany(auth, RoleConstants.companyTakaful)) {
        return AppRoutes.atDashboard;
      }
      if (path == AppRoutes.aiLogin && _matchesOperatorCompany(auth, RoleConstants.companyIttihad)) {
        return AppRoutes.aiDashboard;
      }
      return _roleRoot(role, auth.operatorCode, auth.sessionCompany);
    }

    // Admin cannot open operator-style application review (AT/AI only).
    if (isLoggedIn && role == RoleConstants.admin && path.startsWith('/admin/application/')) {
      return AppRoutes.adminDashboard;
    }

    // 3. Role-based section enforcement (stay in correct lanes)
    if (isLoggedIn && !isPublic && !isAuthOnly) {
      if (_isAdminPath(path) && role != RoleConstants.admin) {
        return _roleRoot(role, auth.operatorCode, auth.sessionCompany);
      }

      // Operator portals (AT/AI) including surplus — operators only, not admin/client.
      if (_isOperatorDashboardPath(path)) {
        if (role == RoleConstants.admin) return AppRoutes.adminDashboard;
        if (role != RoleConstants.operator && !_hasOperatorCompanySession(auth)) {
          return _roleRoot(role, auth.operatorCode, auth.sessionCompany);
        }
      }

      if (_isSubscriberPath(path) && role != RoleConstants.subscriber && role != RoleConstants.admin) {
        return _roleRoot(role, auth.operatorCode, auth.sessionCompany);
      }

      if (role == RoleConstants.operator || _hasOperatorCompanySession(auth)) {
        final code = auth.operatorCode.isNotEmpty
            ? auth.operatorCode
            : _operatorCodeFromCompany(auth.sessionCompany);
        if (code.isEmpty) {
          return AppRoutes.operatorSelection;
        }
        if (code == RoleConstants.companyIttihad && _isAtDashboardPath(path)) return AppRoutes.aiDashboard;
        if (code == RoleConstants.companyTakaful && _isAiDashboardPath(path)) return AppRoutes.atDashboard;
      }

      // Operator logged in but role not synced yet — allow company portal paths.
      if (_isAtDashboardPath(path) && _matchesOperatorCompany(auth, RoleConstants.companyTakaful)) return null;
      if (_isAiDashboardPath(path) && _matchesOperatorCompany(auth, RoleConstants.companyIttihad)) return null;
    }

    return null; // allow navigation
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static bool _isAdminPath(String path) {
    if (path == AppRoutes.adminLogin || path == AppRoutes.adminRegister) return false;
    return path == '/admin' || path.startsWith('/admin/');
  }

  static bool _isOperatorDashboardPath(String path) =>
      _isAtDashboardPath(path) ||
          _isAiDashboardPath(path) ||
          path.startsWith('/agent/') || path == '/agent' ||
          path == '/operator/surplus' || path == '/operator/offers' || path == '/operator/claims';

  static bool _isAtDashboardPath(String path) {
    final normalized = path.endsWith('/') ? path : '$path/';
    if (!normalized.startsWith('/at/')) return false;
    if (path == AppRoutes.atLogin || path == AppRoutes.atRegister) return false;
    return true;
  }

  static bool _isAiDashboardPath(String path) {
    final normalized = path.endsWith('/') ? path : '$path/';
    if (!normalized.startsWith('/ai/')) return false;
    if (path == AppRoutes.aiLogin || path == AppRoutes.aiRegister) return false;
    return true;
  }

  static bool _isSubscriberPath(String path) =>
      path.startsWith('/client/') || path == '/client' ||
          path == '/quote-form' || path == '/quote-result' ||
          path == '/register/step1' || path == '/register/step2' || path == '/register/step3';

  static String _loginRouteFor(String path) {
    if (_isAdminPath(path)) return AppRoutes.adminLogin;
    if (path.startsWith('/at/')) return AppRoutes.atLogin;
    if (path.startsWith('/ai/')) return AppRoutes.aiLogin;
    return AppRoutes.clientLogin;
  }

  static bool _hasOperatorCompanySession(AuthService auth) {
    final company = auth.sessionCompany;
    return company == RoleConstants.companyTakaful || company == RoleConstants.companyIttihad;
  }

  static bool _matchesOperatorCompany(AuthService auth, String expected) {
    if (auth.userRole == RoleConstants.operator && auth.operatorCode == expected) return true;
    return _operatorCodeFromCompany(auth.sessionCompany) == expected;
  }

  static String _operatorCodeFromCompany(String? company) {
    if (company == null) return '';
    if (company == RoleConstants.companyTakaful || company.contains('takaful')) {
      return RoleConstants.companyTakaful;
    }
    if (company == RoleConstants.companyIttihad || company.contains('ittihad')) {
      return RoleConstants.companyIttihad;
    }
    return '';
  }

  static String _roleRoot(String role, String operatorCode, String? sessionCompany) {
    switch (role) {
      case RoleConstants.admin:
        return AppRoutes.adminDashboard;
      case RoleConstants.operator:
        final code = operatorCode.isNotEmpty ? operatorCode : _operatorCodeFromCompany(sessionCompany);
        if (code.isEmpty) return AppRoutes.operatorSelection;
        return code == RoleConstants.companyIttihad ? AppRoutes.aiDashboard : AppRoutes.atDashboard;
      case RoleConstants.subscriber:
      default:
        if (_operatorCodeFromCompany(sessionCompany) == RoleConstants.companyIttihad) {
          return AppRoutes.aiDashboard;
        }
        if (_operatorCodeFromCompany(sessionCompany) == RoleConstants.companyTakaful) {
          return AppRoutes.atDashboard;
        }
        return AppRoutes.home;
    }
  }

  static String roleRoot(String role, String operatorCode) =>
      _roleRoot(role, operatorCode, AuthService.instance.sessionCompany);
}