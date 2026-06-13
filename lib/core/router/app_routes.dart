import 'package:flutter/widgets.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AppRoutes {
  AppRoutes._();

  // ─── AUTH & COMMON ──────────────────────────────────────────────────────────
  static const splash            = '/';
  static const onboarding        = '/onboarding';
  static const welcome           = '/welcome';
  static const roleSelection     = '/role';
  static const roleClient        = '/role/client';
  static const roleOperator      = '/role/operator';
  static const clientLogin       = '/client/login';
  static const adminLogin        = '/admin/login';
  static const otpVerify         = '/client/auth/otp';
  static const forgotPassword    = '/client/reset-password';
  static const operatorRegister  = '/operator/register';

  // ─── CLIENT PORTAL ─────────────────────────────────────────────────────────
  static const home              = '/client';
  static const myPolicies        = '/client/policies';
  static const policyDetail      = '/client/policies/:id';
  static const myClaims          = '/client/claims';
  static const submitClaim        = '/client/claims/submit';
  static const claimDetail        = '/client/claims/:id';
  static const insuranceRequest  = '/client/insurance-request';
  static const claimRequest      = '/client/claim-request';
  static const profile           = '/client/settings';
  static const registerStep1     = '/register/step1';
  static const registerStep2     = '/register/step2';
  static const registerStep3     = '/register/step3';
  static const quoteForm         = '/quote-form';
  static const quoteResult       = '/quote-result';
  static const checkout          = '/client/checkout';
  static const paymentSuccess    = '/client/payment-success';
  static const roadsideAssist    = '/client/roadside';
  static const rafikCalculator   = '/client/calculator/rafik';
  static const sos               = '/client/sos';
  static const agentDashboard    = '/agent/dashboard';
  static const notifications     = '/notifications';
  static const legalHub          = '/client/legal';
  static const support           = '/client/support';
  static const payment           = '/client/payment/:id';
  static const policyDocuments   = '/client/policy-documents/:id';
  static const clientOperatorIttihad = '/client/operators/ittihad';
  static const clientOperatorTakaful = '/client/operators/takaful';
  static const clientPhoneLogin  = '/client/login/phone';

  // ─── OPERATOR PORTAL (Algeria Takaful) ─────────────────────────────────────
  static const atLogin           = '/at/login';
  static const atRegister        = '/at/register';
  static const atDashboard       = '/at/dashboard';
  static const atSurplus         = '/at/surplus';
  static const atSettings        = '/at/settings';
  static const atPolicies        = '/at/policies';
  static const atApplication     = '/at/application/:id';
  static const atClaims          = '/at/claims';
  static const atClaimDetail     = '/at/claim/:id';
  static const atOffers          = '/at/offers';
  static const atNotifications   = '/at/notifications';

  // ─── OPERATOR PORTAL (Al-Ittihad) ──────────────────────────────────────────
  static const aiLogin           = '/ai/login';
  static const aiRegister        = '/ai/register';
  static const aiDashboard       = '/ai/dashboard';
  static const aiSurplus         = '/ai/surplus';
  static const aiSettings        = '/ai/settings';
  static const aiPolicies        = '/ai/policies';
  static const aiApplication     = '/ai/application/:id';
  static const aiClaims          = '/ai/claims';
  static const aiClaimDetail     = '/ai/claim/:id';
  static const aiOffers          = '/ai/offers';
  static const aiNotifications   = '/ai/notifications';
  
  // Aliases for backward compatibility
  static const takafulDashboard  = atDashboard;
  static const ittihadDashboard  = aiDashboard;
  static const login             = clientLogin;
  static const register          = registerStep1;
  static const operatorSelection = roleOperator; // Map selection to the gate screen

  // ─── OPERATOR SHARED ───────────────────────────────────────────────────────
  static const operatorPolicies  = '/operator/policies';
  static const operatorClaims    = '/operator/claims';
  static const operatorOffers    = '/operator/offers';
  static const operatorSurplus   = '/operator/surplus';

  // ─── ADMIN PORTAL ──────────────────────────────────────────────────────────
  static const adminDashboard    = '/admin/dashboard';
  static const adminUsers        = '/admin/users';
  static const adminClaims       = '/admin/claims';
  static const adminPlans        = '/admin/plans';
  static const adminAddPlan      = '/admin/plans/add';
  static const adminSales        = '/admin/sales';
  static const adminCommission   = '/admin/commission';
  static const adminAudit        = '/admin/audit';
  static const adminWallet       = '/admin/wallet';
  static const adminWithdraw     = '/admin/wallet/withdraw';
  static const adminSettings     = '/admin/settings';
  static const adminNotifications = '/admin/notifications';
  static const adminRegister     = '/admin/register';
  static const adminApplication  = '/admin/application/:id';
  static const adminUserDetail   = '/admin/users/:id';

  // ─── STATIC & LEGAL ────────────────────────────────────────────────────────
  static const about             = '/about';
  static const privacyPolicy     = '/privacy';
  static const termsAndConditions = '/terms';
  static const howTakafulWorks   = '/how-takaful-works';
  static const legalFramework    = '/legal-framework';
  static const faq               = '/faq';
  static const contactUs         = '/contact';
  static const plans             = '/client/plans';
  static const planDetail        = '/client/plans/:planId';

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  static String clientPayment(String id) => '/client/payment/$id';
  static String policyDetailPath(String id) => '/client/policies/$id';

  // ─── CENTRALIZED DYNAMIC TRANSLATION HELPER ──────────────────────────────
  /// Resolves the localized display name for any active route path.
  /// Used in browser tabs, app bars, or breadcrumbs to support dynamic locale sync.
  static String getRouteTitle(BuildContext context, String path) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'تأميني';

    // 1. Dashboards
    if (path == home) return l10n.clientPortal;
    if (path == atDashboard || path == aiDashboard || path == adminDashboard) return l10n.dashboard;

    // 2. Client Screens
    if (path == plans) return l10n.plans;
    if (path == legalHub) return l10n.legal;
    if (path == support) return l10n.support;
    if (path == profile) return l10n.profile;
    if (path == myPolicies) return l10n.policies;
    if (path == myClaims) return l10n.myClaims;
    if (path == welcome || path == onboarding) return l10n.welcome;

    // 3. Operator Screens
    if (path == atSurplus || path == aiSurplus) return l10n.surplus;
    if (path == atPolicies || path == aiPolicies) return l10n.policies;
    if (path == atSettings || path == aiSettings) return l10n.settings;
    if (path == atClaims || path == aiClaims) return l10n.claims;

    // 4. Pattern / Dynamic Segment matches
    if (path.startsWith('/client/policies/')) return l10n.policies;
    if (path.startsWith('/client/payment/')) return l10n.electronicPayment;
    if (path.startsWith('/at/application/')) return l10n.policies;
    if (path.startsWith('/ai/application/')) return l10n.policies;
    if (path.startsWith('/admin/users/')) return l10n.userManagement;
    if (path == adminWallet) return l10n.totalWallet;
    if (path == adminWithdraw) return l10n.withdraw;

    return l10n.appTitle;
  }
}
