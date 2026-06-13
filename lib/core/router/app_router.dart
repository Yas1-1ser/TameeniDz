// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/router/route_guards.dart';
import 'package:tameenidz/core/router/route_arguments.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/services/auth_service.dart';
import 'package:tameenidz/features/client/plans/plan_detail_screen.dart';

// Splash & Onboarding
import 'package:tameenidz/features/splash/screens/app_boot_screen.dart';
import 'package:tameenidz/features/splash/screens/splash_screen.dart';
import 'package:tameenidz/features/onboarding/screens/onboarding_screen.dart';
import 'package:tameenidz/features/onboarding/role_picker_screen.dart';
import 'package:tameenidz/features/operator/screens/operator_auth_gate_screen.dart';

// Client Auth
import 'package:tameenidz/features/client/auth/client_auth_gate_screen.dart';
import 'package:tameenidz/features/client/auth/client_login_screen.dart';
import 'package:tameenidz/features/client/auth/reset_password_screen.dart';
import 'package:tameenidz/features/client/auth/registration/steps/step1_personal_info.dart';
import 'package:tameenidz/features/client/auth/registration/steps/step2_password_setup.dart';
import 'package:tameenidz/features/client/auth/registration/steps/step3_document_upload.dart';
import 'package:tameenidz/features/client/auth/otp/otp_verification_screen.dart';

// Client Portal
import 'package:tameenidz/features/client/home/client_dashboard_screen.dart';
import 'package:tameenidz/features/client/plans/plan_comparison_screen.dart';
import 'package:tameenidz/features/client/payment/payment_screen.dart';
import 'package:tameenidz/features/client/legal_hub/legal_hub_screen.dart';
import 'package:tameenidz/features/client/support/support_screen.dart';
import 'package:tameenidz/features/client/settings/client_settings_screen.dart';
import 'package:tameenidz/features/client/policies/client_policies_screen.dart';
import 'package:tameenidz/features/client/policies/client_policy_detail_screen.dart';
import 'package:tameenidz/features/client/policies/policy_document_upload_screen.dart';
import 'package:tameenidz/features/client/claims/my_claims_screen.dart';
import 'package:tameenidz/features/client/claims/submit_claim_screen.dart';
import 'package:tameenidz/features/client/claims/client_claim_detail_screen.dart';
import 'package:tameenidz/features/client/checkout/checkout_screen.dart';
import 'package:tameenidz/features/client/checkout/payment_success_screen.dart';
import 'package:tameenidz/features/client/roadside/roadside_assistance_screen.dart';
import 'package:tameenidz/features/client/quotes/quote_request_wizard_screen.dart';
import 'package:tameenidz/features/client/quotes/insurance_request_wizard_screen.dart';
import 'package:tameenidz/features/client/quotes/claim_request_wizard_screen.dart';
import 'package:tameenidz/features/client/quotes/quote_result_screen.dart';
import 'package:tameenidz/features/client/notifications/notifications_screen.dart';
import 'package:tameenidz/features/client/faq/faq_screen.dart';
import 'package:tameenidz/features/client/contact/contact_us_screen.dart';

import 'package:tameenidz/features/client/screens/sos_screen.dart';
import 'package:tameenidz/features/client/operators/presentation/screens/algerie_takaful_screen.dart';
import 'package:tameenidz/features/client/operators/presentation/screens/algerie_ittihad_screen.dart';

// Operator Shared / Auth
import 'package:tameenidz/features/algeria_takaful/auth/at_login_screen.dart';
// at_register_screen removed
import 'package:tameenidz/features/al_ittihad/auth/ai_login_screen.dart';
// ai_register_screen removed

// Decoupled Algeria Takaful Operators
import 'package:tameenidz/features/operator/algeria_takaful/dashboard/at_dashboard_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/surplus/at_surplus_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/policies/at_policies_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/policies/at_application_detail_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/claims/at_claims_screen.dart';
import 'package:tameenidz/features/operator/shared/operator_claim_detail_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/offers/at_offers_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/settings/at_settings_screen.dart';
import 'package:tameenidz/features/operator/algeria_takaful/notifications/at_notifications_screen.dart';

// Decoupled Al-Ittihad Operators
import 'package:tameenidz/features/operator/algerie_ittihadd/dashboard/ai_dashboard_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/surplus/ai_surplus_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/policies/ai_policies_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/policies/ai_application_detail_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/claims/ai_claims_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/offers/ai_offers_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/settings/ai_settings_screen.dart';
import 'package:tameenidz/features/operator/algerie_ittihadd/notifications/ai_notifications_screen.dart';

// Shared Agent
import 'package:tameenidz/features/operator/screens/agent_dashboard_screen.dart';

// Admin
import 'package:tameenidz/features/admin/auth/admin_login_screen.dart';
import 'package:tameenidz/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:tameenidz/features/admin/dashboard/admin_application_detail_screen.dart';
import 'package:tameenidz/features/admin/commission/commission_monitor_screen.dart';
import 'package:tameenidz/features/admin/audit_trail/audit_trail_screen.dart';
import 'package:tameenidz/features/admin/user_management/user_management_screen.dart';
import 'package:tameenidz/features/admin/user_management/admin_user_detail_screen.dart';
import 'package:tameenidz/features/admin/claims_management/claims_management_screen.dart';
import 'package:tameenidz/features/admin/plans/admin_plans_screen.dart';
import 'package:tameenidz/features/admin/plans/admin_add_plan_screen.dart';
import 'package:tameenidz/features/admin/sales/admin_sales_screen.dart';
import 'package:tameenidz/features/admin/wallet/wallet_screen.dart';
import 'package:tameenidz/features/admin/wallet/withdraw_screen.dart';
import 'package:tameenidz/features/admin/notifications/admin_notifications_screen.dart';
import 'package:tameenidz/features/admin/settings/admin_settings_screen.dart';

// Static / About
import 'package:tameenidz/core/about/about_us_screen.dart';
import 'package:tameenidz/core/about/privacy_policy_screen.dart';
import 'package:tameenidz/core/about/terms_screen.dart';
import 'package:tameenidz/core/about/how_takaful_works_screen.dart';
import 'package:tameenidz/core/about/legal_framework_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: RouteGuards.authGuard,
    refreshListenable: AuthService.instance,
    routes: [
      GoRoute(path: AppRoutes.splash, pageBuilder: (c, s) => _buildPageWithAnimation(const AppBootScreen())),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (c, s) => _buildPageWithAnimation(const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (c, s) => _buildPageWithAnimation(const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (c, s) => _buildPageWithAnimation(const RolePickerScreen()),
      ),
      GoRoute(
        path: AppRoutes.roleClient,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClientAuthGateScreen()),
      ),
      GoRoute(
        path: AppRoutes.roleOperator,
        pageBuilder: (c, s) => _buildPageWithAnimation(const OperatorAuthGateScreen()),
      ),

      // CLIENT AUTH
      GoRoute(
        path: AppRoutes.clientLogin,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClientLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.clientPhoneLogin,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClientLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ResetPasswordScreen()),
      ),
      GoRoute(
        path: AppRoutes.registerStep1,
        pageBuilder: (c, s) => _buildPageWithAnimation(const Step1PersonalInfo()),
      ),
      GoRoute(
        path: AppRoutes.registerStep2,
        pageBuilder: (c, s) {
          final extra = s.extra;
          RegisterStep2Args? args;
          Map<String, dynamic>? map;
          if (extra is RegisterStep2Args) {
            args = extra;
          } else if (extra is Map<String, dynamic>) {
            map = extra;
          }
          return _buildPageWithAnimation(Step2PasswordSetup(
            email: args?.email ?? map?['email'] ?? '',
            fullName: args?.fullName ?? map?['fullName'] ?? '',
            phoneNumber: args?.phoneNumber ?? map?['phoneNumber'] ?? '',
            ccpNumber: args?.ccpNumber ?? map?['ccpNumber'] ?? '',
            nin: args?.nin ?? map?['nin'],
            wilaya: args?.wilaya ?? map?['wilaya'],
            dob: args?.dob ?? map?['dob'],
          ));
        },
      ),
      GoRoute(
        path: AppRoutes.registerStep3,
        pageBuilder: (c, s) => _buildPageWithAnimation(const Step3DocumentUpload()),
      ),
      GoRoute(
        path: AppRoutes.otpVerify,
        pageBuilder: (c, s) {
          final extra = s.extra;
          OtpVerificationArgs? args;
          Map<String, dynamic>? map;
          if (extra is OtpVerificationArgs) {
            args = extra;
          } else if (extra is Map<String, dynamic>) {
            map = extra;
          }
          return _buildPageWithAnimation(OtpVerificationScreen(
            verificationId:
                args?.verificationId ?? map?['verificationId'] ?? '',
            phoneNumber: args?.phoneNumber ?? map?['phoneNumber'] ?? '',
            isRegistration:
                args?.isRegistration ?? map?['isRegistration'] ?? false,
            email: args?.email ?? map?['email'],
            fullName: args?.fullName ?? map?['fullName'],
            ccpNumber: args?.ccpNumber ?? map?['ccpNumber'],
            nin: args?.nin ?? map?['nin'],
            wilaya: args?.wilaya ?? map?['wilaya'],
            dob: args?.dob ?? map?['dob'],
          ));
        },
      ),

      // CLIENT PORTAL
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClientDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.plans,
        pageBuilder: (c, s) => _buildPageWithAnimation(PlanComparisonScreen(policyId: s.uri.queryParameters['policyId'])),
      ),
      GoRoute(
        path: AppRoutes.planDetail,
        pageBuilder: (c, s) => _buildPageWithAnimation(PlanDetailScreen(planId: s.pathParameters['planId'] ?? '')),
      ),
      GoRoute(
        path: '/client/payment/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(PaymentScreen(policyId: s.pathParameters['id'])),
      ),
      GoRoute(
        path: AppRoutes.legalHub,
        pageBuilder: (c, s) => _buildPageWithAnimation(const LegalHubScreen()),
      ),
      GoRoute(
        path: AppRoutes.support,
        pageBuilder: (c, s) => _buildPageWithAnimation(const SupportScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClientSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.myPolicies,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClientPoliciesScreen()),
      ),
      GoRoute(
        path: '/client/policies/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(ClientPolicyDetailScreen(policyId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/client/policy-documents/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(PolicyDocumentUploadScreen(policyId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.myClaims,
        pageBuilder: (c, s) => _buildPageWithAnimation(const MyClaimsScreen()),
      ),
      GoRoute(
        path: AppRoutes.submitClaim,
        pageBuilder: (c, s) => _buildPageWithAnimation(const SubmitClaimScreen()),
      ),
      GoRoute(
        path: '/client/claims/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(
          ClientClaimDetailScreen(claimId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.insuranceRequest,
        pageBuilder: (c, s) => _buildPageWithAnimation(InsuranceRequestWizardScreen(extra: s.extra)),
      ),
      GoRoute(
        path: AppRoutes.claimRequest,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClaimRequestWizardScreen()),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (c, s) => _buildPageWithAnimation(const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        pageBuilder: (c, s) => _buildPageWithAnimation(const PaymentSuccessScreen()),
      ),
      GoRoute(
        path: AppRoutes.roadsideAssist,
        pageBuilder: (c, s) => _buildPageWithAnimation(const RoadsideAssistanceScreen()),
      ),
      GoRoute(path: AppRoutes.sos, pageBuilder: (c, s) => _buildPageWithAnimation(const SosScreen())),

      GoRoute(
        path: AppRoutes.clientOperatorTakaful,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AlgerieTakafulScreen()),
      ),
      GoRoute(
        path: AppRoutes.clientOperatorIttihad,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AlgerieIttihadScreen()),
      ),
      GoRoute(
        path: AppRoutes.quoteForm,
        pageBuilder: (c, s) => _buildPageWithAnimation(QuoteRequestWizardScreen(extra: s.extra)),
      ),
      GoRoute(
        path: AppRoutes.quoteResult,
        pageBuilder: (c, s) {
          final args =
              s.extra as QuoteResultArgs? ??
              const QuoteResultArgs(
                calculatedPremium: 120000.0,
                formData: {},
                planName: 'Elite Plan',
                operatorCode: 'algeria_takaful',
              );
          return _buildPageWithAnimation(QuoteResultScreen(args: args));
        },
      ),

      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (c, s) => _buildPageWithAnimation(const NotificationsScreen()),
      ),

      // STATIC / LEGAL PAGES
      GoRoute(path: AppRoutes.faq, pageBuilder: (c, s) => _buildPageWithAnimation(const FaqScreen())),
      GoRoute(
        path: AppRoutes.contactUs,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ContactUsScreen()),
      ),
      GoRoute(path: AppRoutes.about, pageBuilder: (c, s) => _buildPageWithAnimation(const AboutUsScreen())),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        pageBuilder: (c, s) => _buildPageWithAnimation(const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: AppRoutes.termsAndConditions,
        pageBuilder: (c, s) => _buildPageWithAnimation(const TermsScreen()),
      ),
      GoRoute(
        path: AppRoutes.howTakafulWorks,
        pageBuilder: (c, s) => _buildPageWithAnimation(const HowTakafulWorksScreen()),
      ),
      GoRoute(
        path: AppRoutes.legalFramework,
        pageBuilder: (c, s) => _buildPageWithAnimation(const LegalFrameworkScreen()),
      ),

      // ALGERIA TAKAFUL PORTAL
      GoRoute(
        path: AppRoutes.atLogin,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtLoginScreen()),
      ),
      // AT register removed - accounts are static (SQL-managed)
      GoRoute(
        path: AppRoutes.atRegister,
        redirect: (c, s) => AppRoutes.atLogin,
      ),
      GoRoute(
        path: AppRoutes.atDashboard,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AlgeriaTakafulDashboardScreen()),
      ),
      GoRoute(
        path: '/at/application/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(AtApplicationDetailScreen(
          id: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.atSurplus,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtSurplusScreen()),
      ),
      GoRoute(
        path: AppRoutes.atPolicies,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtPoliciesScreen()),
      ),
      GoRoute(
        path: AppRoutes.atClaims,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtClaimsScreen()),
      ),
      GoRoute(
        path: '/at/claim/:id',
        pageBuilder: (c, s) {
          final source = s.uri.queryParameters['source'] ?? 'legacy';
          return _buildPageWithAnimation(OperatorClaimDetailScreen(
            claimId: s.pathParameters['id']!,
            source: source,
            operatorCode: 'algeria_takaful',
          ));
        },
      ),
      GoRoute(
        path: AppRoutes.atSettings,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.atOffers,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtOffersScreen()),
      ),
      GoRoute(
        path: AppRoutes.atNotifications,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AtNotificationsScreen()),
      ),

      // AL-ITTIHAD PORTAL
      GoRoute(
        path: AppRoutes.aiLogin,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiLoginScreen()),
      ),
      // AI register removed - accounts are static (SQL-managed)
      GoRoute(
        path: AppRoutes.aiRegister,
        redirect: (c, s) => AppRoutes.aiLogin,
      ),
      GoRoute(
        path: AppRoutes.aiDashboard,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AlgerieIttihaddDashboardScreen()),
      ),
      GoRoute(
        path: '/ai/application/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(AiApplicationDetailScreen(
          id: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSurplus,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiSurplusScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiPolicies,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiPoliciesScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiClaims,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiClaimsScreen()),
      ),
      GoRoute(
        path: '/ai/claim/:id',
        pageBuilder: (c, s) {
          final source = s.uri.queryParameters['source'] ?? 'legacy';
          return _buildPageWithAnimation(OperatorClaimDetailScreen(
            claimId: s.pathParameters['id']!,
            source: source,
            operatorCode: 'al_ittihad',
          ));
        },
      ),
      GoRoute(
        path: AppRoutes.aiSettings,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiOffers,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiOffersScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiNotifications,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AiNotificationsScreen()),
      ),

      GoRoute(
        path: AppRoutes.agentDashboard,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AgentDashboardScreen()),
      ),

      // MASTER ADMIN
      GoRoute(
        path: AppRoutes.adminLogin,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminCommission,
        pageBuilder: (c, s) => _buildPageWithAnimation(const CommissionMonitorScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminAudit,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AuditTrailScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        pageBuilder: (c, s) => _buildPageWithAnimation(const UserManagementScreen()),
      ),
      GoRoute(
        path: '/admin/users/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(AdminUserDetailScreen(userId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminClaims,
        pageBuilder: (c, s) => _buildPageWithAnimation(const ClaimsManagementScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminAddPlan,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminAddPlanScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminPlans,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminPlansScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminSales,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminSalesScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminWallet,
        pageBuilder: (c, s) => _buildPageWithAnimation(const WalletScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminWithdraw,
        pageBuilder: (c, s) => _buildPageWithAnimation(const WithdrawScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminNotifications,
        pageBuilder: (c, s) => _buildPageWithAnimation(const AdminNotificationsScreen()),
      ),
      GoRoute(
        path: '/admin/application/:id',
        pageBuilder: (c, s) => _buildPageWithAnimation(AdminApplicationDetailScreen(id: s.pathParameters['id']!)),
      ),
    ],
  );

  static CustomTransitionPage _buildPageWithAnimation(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeIn).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
