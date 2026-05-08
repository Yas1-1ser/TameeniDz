import 'package:go_router/go_router.dart';
import '../../features/client/onboarding/app_boot_screen.dart';
import '../../features/client/onboarding/splash_screen.dart';
import '../../features/onboarding/role_picker_screen.dart';
import '../../features/client/auth/client_auth_gate_screen.dart';
import '../../features/client/auth/client_login_screen.dart';
import '../../features/client/auth/reset_password_screen.dart';
import '../../features/client/auth/registration/steps/step1_personal_info.dart';
import '../../features/client/auth/registration/steps/step2_password_setup.dart';
import '../../features/client/auth/otp/otp_verification_screen.dart';
import '../../features/client/auth/registration/steps/step3_document_upload.dart';
import '../../features/client/policies/policy_document_upload_screen.dart';
import '../../features/client/home/client_dashboard_screen.dart';
import '../../features/client/plans/plan_comparison_screen.dart';
import '../../features/client/payment/payment_screen.dart';
import '../../features/client/legal_hub/legal_hub_screen.dart';
import '../../features/algeria_takaful/auth/at_login_screen.dart';
import '../../features/algeria_takaful/auth/at_register_screen.dart';
import '../../features/operator/dashboard/operator_dashboard_screen.dart';
import '../../features/operator/operator_application_details_screen.dart';
import '../../features/algeria_takaful/surplus/at_surplus_log_screen.dart';
import '../../features/al_ittihad/auth/ai_login_screen.dart';
import '../../features/al_ittihad/auth/ai_register_screen.dart';
import '../../features/operator/auth/operator_register_screen.dart';
import '../../features/al_ittihad/surplus/ai_surplus_log_screen.dart';
import '../../features/admin/auth/admin_login_screen.dart';
import '../../features/admin/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/commission/commission_monitor_screen.dart';
import '../../features/admin/audit_trail/audit_trail_screen.dart';
import '../../features/admin/user_management/user_management_screen.dart';
import '../../features/client/support/support_screen.dart';
import '../../features/client/settings/client_settings_screen.dart';
import '../../features/client/policies/client_policies_screen.dart';
import '../../features/operator/operator_policies_screen.dart';
import '../../features/onboarding/operator_auth_gate_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // ── ONBOARDING ──────────────────────────────────────────────
      // Boot (reload) screen → onboarding splash → role picker → auth
      GoRoute(path: '/', builder: (c, s) => const AppBootScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/role', builder: (c, s) => const RolePickerScreen()),

      // ── CLIENT ──────────────────────────────────────────────────
      // /role/client → pick login or register
      GoRoute(
        path: '/role/client',
        builder: (c, s) => const ClientAuthGateScreen(),
      ),
      GoRoute(
        path: '/role/operator',
        builder: (c, s) => const OperatorAuthGateScreen(),
      ),
      // Login for returning clients
      GoRoute(
        path: '/client/login',
        builder: (c, s) => const ClientLoginScreen(),
      ),
      // Registration flow: step1 → otp → step3
      GoRoute(
        path: '/register/step1',
        builder: (c, s) => const Step1PersonalInfo(),
      ),
      GoRoute(
        path: '/register/step2',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return Step2PasswordSetup(
            email: extra['email'] ?? '',
            fullName: extra['fullName'] ?? '',
            phoneNumber: extra['phoneNumber'] ?? '',
            ccpNumber: extra['ccpNumber'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/client/auth/otp',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            verificationId: extra['verificationId'] ?? '',
            phoneNumber: extra['phoneNumber'] ?? '',
            isRegistration: extra['isRegistration'] ?? false,
            email: extra['email'],
            fullName: extra['fullName'],
            ccpNumber: extra['ccpNumber'],
          );
        },
      ),
      GoRoute(
        path: '/register/step3',
        builder: (c, s) => const Step3DocumentUpload(),
      ),
      GoRoute(
        path: '/client',
        builder: (c, s) => const ClientDashboardScreen(),
      ),
      GoRoute(
        path: '/client/plans',
        builder: (c, s) => const PlanComparisonScreen(),
      ),
      GoRoute(
        path: '/client/payment/:id',
        builder: (c, s) => PaymentScreen(policyId: s.pathParameters['id']),
      ),
      GoRoute(path: '/client/legal', builder: (c, s) => const LegalHubScreen()),
      GoRoute(
        path: '/client/support',
        builder: (c, s) => const SupportScreen(),
      ),
      GoRoute(
        path: '/client/policies',
        builder: (c, s) => const ClientPoliciesScreen(),
      ),
      GoRoute(
        path: '/client/policy-documents/:id',
        builder: (c, s) => PolicyDocumentUploadScreen(policyId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/client/settings',
        builder: (c, s) => const ClientSettingsScreen(),
      ),
      GoRoute(
        path: '/client/reset-password',
        builder: (c, s) => const ResetPasswordScreen(),
      ),

      // ── ALGERIA TAKAFUL ─────────────────────────────────────────
      GoRoute(path: '/at/login', builder: (c, s) => const AtLoginScreen()),
      GoRoute(
        path: '/at/dashboard',
        builder:
            (c, s) => const OperatorDashboardScreen(company: 'algeria_takaful'),
      ),
      GoRoute(
        path: '/at/application/:id',
        builder:
            (c, s) => OperatorApplicationDetailScreen(
              id: s.pathParameters['id']!,
              company: 'algeria_takaful',
            ),
      ),
      GoRoute(
        path: '/at/surplus',
        builder: (c, s) => const AtSurplusLogScreen(),
      ),
      GoRoute(
        path: '/at/policies',
        builder: (c, s) => const OperatorPoliciesScreen(company: 'algeria_takaful'),
      ),
      GoRoute(
        path: '/at/settings',
        builder: (c, s) => const ClientSettingsScreen(),
      ),
      GoRoute(path: '/at/register', builder: (c, s) => const AtRegisterScreen()),

      // ── AL-ITTIHAD ───────────────────────────────────────────────
      GoRoute(path: '/ai/login', builder: (c, s) => const AiLoginScreen()),
      GoRoute(
        path: '/operator/register',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return OperatorRegisterScreen(preselectedCompany: extra['company']);
        },
      ),
      GoRoute(
        path: '/ai/dashboard',
        builder: (c, s) => const OperatorDashboardScreen(company: 'al_ittihad'),
      ),
      GoRoute(
        path: '/ai/application/:id',
        builder:
            (c, s) => OperatorApplicationDetailScreen(
              id: s.pathParameters['id']!,
              company: 'al_ittihad',
            ),
      ),
      GoRoute(
        path: '/ai/surplus',
        builder: (c, s) => const AiSurplusLogScreen(),
      ),
      GoRoute(
        path: '/ai/policies',
        builder: (c, s) => const OperatorPoliciesScreen(company: 'al_ittihad'),
      ),
      GoRoute(
        path: '/ai/settings',
        builder: (c, s) => const ClientSettingsScreen(),
      ),
      GoRoute(path: '/ai/register', builder: (c, s) => const AiRegisterScreen()),

      // ── MASTER ADMIN ─────────────────────────────────────────────
      GoRoute(
        path: '/admin/login',
        builder: (c, s) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (c, s) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/commission',
        builder: (c, s) => const CommissionMonitorScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (c, s) => const AuditTrailScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (c, s) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (c, s) => const ClientSettingsScreen(),
      ),
    ],
  );
}
