import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';

/// App reload / boot screen.
///
/// Shown every time the app cold-starts (registered as the initial route '/')
/// before the SplashScreen. Shows the Taminy Elite logo with a pulse animation
/// and a loading indicator, then:
///  - redirects authenticated users straight to /client/home
///  - redirects unauthenticated users to /onboarding
///
/// Usage in app_router.dart — replace the '/' route with:
///   GoRoute(path: '/', builder: (c, s) => const AppBootScreen()),
///   GoRoute(path: '/onboarding', builder: (c, s) => const SplashScreen()),
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

  @override
  void dispose() {
    _pulse.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool _redirected = false;

  Future<void> _bootstrap() async {
    debugPrint('DEBUG: AppBootScreen bootstrap started');
    // Listen for auth state changes (especially for password recovery deep links)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted && !_redirected) {
          _redirected = true;
          context.go('/client/reset-password');
        }
      }
    });

    try {
      // Check if the user is already logged in
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final userId = session.user.id;

        // Fetch user data from public.users table for security
        final data = await Supabase.instance.client
            .from('users')
            .select('role, company')
            .eq('id', userId)
            .maybeSingle();

        if (!mounted || _redirected) return;
        _redirected = true;

        // Small delay to prevent jitter and let the logo animation start
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        if (data != null) {
          final role = data['role'] as String?;
          final company = data['company'] as String?;

          if (role == 'admin') {
            context.go('/admin/dashboard');
          } else if (role == 'employee' || role == 'operator') {
            if (company == 'algeria_takaful') {
              context.go('/at/dashboard');
            } else if (company == 'al_ittihad') {
              context.go('/ai/dashboard');
            } else {
              context.go('/onboarding');
            }
          } else {
            // Default to client dashboard
            context.go('/client');
          }
        } else {
          // If no record in users table, default to onboarding
          context.go('/onboarding');
        }
        return;
      }
    } catch (e) {
      debugPrint('Error during bootstrap: $e');
    }

    // Minimum display time for new users
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || _redirected) return;

    _redirected = true;
    debugPrint('DEBUG: AppBootScreen redirecting to /onboarding');
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Pulsing logo ────────────────────────────────────
              ScaleTransition(scale: _pulseAnim, child: _buildLogo()),

              const SizedBox(height: 32),

              const SizedBox(height: 48),

              // ── Slim loading bar ────────────────────────────────
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: context.colors.bootButtonBg,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('assets/images/logotameen.jpeg', fit: BoxFit.cover),
    );
  }
}
