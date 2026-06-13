import 'dart:async';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/services/auth_service.dart';
import 'package:tameenidz/core/constants/role_constants.dart';

/// App reload / boot screen.
///
/// Every cold start hits this screen (route: /) first.
class AppBootScreen extends ConsumerStatefulWidget {
  const AppBootScreen({super.key});

  @override
  ConsumerState<AppBootScreen> createState() => _AppBootScreenState();
}

class _AppBootScreenState extends ConsumerState<AppBootScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _bootstrap();
  }

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _pulse.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool _redirected = false;

  Future<void> _bootstrap() async {
    debugPrint('DEBUG: AppBootScreen bootstrap started');

    final auth = AuthService.instance;

    // 1. Wait for AuthService to initialize its internal state (isLoggedIn, userRole, etc)
    // This prevents the RouteGuard from redirecting to login while the session is being restored.
    int attempts = 0;
    while (!auth.isInitialized && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      attempts++;
    }

    // 2. Listen for password recovery deep links
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted && !_redirected) {
          _redirected = true;
          context.go(AppRoutes.forgotPassword);
        }
      }
    });

    if (_redirected) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
      final bool isLoggedIn = auth.isLoggedIn;

      _redirected = true;

      // Allow animations to play slightly
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // 3. Authenticated user flow
      if (isLoggedIn) {
        final role = auth.userRole;
        final company = auth.operatorCode;

        debugPrint(
          'DEBUG: Authenticated user (Role: $role). Routing to dashboard.',
        );

        if (role == RoleConstants.admin) {
          context.go(AppRoutes.adminDashboard);
        } else if (role == RoleConstants.operator) {
          if (company == RoleConstants.companyIttihad) {
            context.go(AppRoutes.aiDashboard);
          } else {
            context.go(AppRoutes.atDashboard);
          }
        } else {
          context.go(AppRoutes.home);
        }
        return;
      }

      // 4. Unauthenticated user flow
      if (!onboardingDone) {
        debugPrint('DEBUG: First launch. Going to /onboarding (SplashScreen)');
        context.go(AppRoutes.onboarding);
      } else {
        debugPrint('DEBUG: Returning user. Skipping onboarding to /role');
        context.go(AppRoutes.roleSelection);
      }
    } catch (e) {
      debugPrint('Error during bootstrap: $e');
      if (mounted) context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageEntryAnimation(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  const Color(0xFFFFFDF9),
                  context.colors.beigeBg,
                  const Color(0xFFF2ECE0),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  ScaleTransition(scale: _pulseAnim, child: _buildLogo()),
                  const SizedBox(height: 36),
                  const Text(
                    'TAMEENI ELITE',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      color: AppColors.goldDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SOVEREIGN TRUST • DIGITAL TAKAFUL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: AppColors.goldDeep.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: 140,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            backgroundColor: Color(0x1AD4AF37),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.goldAccent,
                            ),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading secure portal...',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.goldDeep.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withValues(alpha: 0.25),
            blurRadius: 35,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.goldAccent,
              AppColors.goldLight,
              AppColors.goldDeep,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surface,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/images/logotameen.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
