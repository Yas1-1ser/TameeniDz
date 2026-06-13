import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/splash/widgets/floating_particles.dart';
import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/core/services/auth_service.dart';
import 'package:tameenidz/core/constants/role_constants.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class AiLoginScreen extends StatefulWidget {
  const AiLoginScreen({super.key});

  @override
  State<AiLoginScreen> createState() => _AiLoginScreenState();
}

class _AiLoginScreenState extends State<AiLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _obscurePw = true;
  bool _loading = false;
  String? _error;

  static const _accent = AppColors.alIttihadGreen;
  static const _dark = Color(0xFF073D27);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
      );

      final company = res.user?.userMetadata?['company'] as String?;
      if (company != 'al_ittihad') {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          final locale = Localizations.localeOf(context).languageCode;
          setState(() => _error = AuthExceptionHandler.translateCode('company_mismatch_ittihad', locale));
        }
        return;
      }

      AuthService.instance.applyOperatorSession(RoleConstants.companyIttihad);
      await AuthService.instance.refreshRoleFromSession();
      if (mounted) context.go(AppRoutes.aiDashboard);
    } on AuthException catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() => _error = AuthExceptionHandler.translate(e, locale));
      }
    } catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() => _error = AuthExceptionHandler.translateCode('auth_unexpected_error', locale));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.goldAccent.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
              color: _accent,
              size: 16,
            ),
          ),
          onPressed: () => context.go('/role/operator'),
        ),
        actions: const [
          LanguagePickerButton(),
          SizedBox(width: 16),
        ],
      ),
      body: PageEntryAnimation(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.3),
                    radius: 1.2,
                    colors: isDark 
                      ? [
                          colors.background,
                          colors.surface,
                          colors.surfaceContainerLow,
                        ]
                      : [
                          const Color(0xFFFFFDF9),
                          const Color(0xFFF9F6F0),
                          const Color(0xFFF2ECE0),
                        ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: FloatingParticles(count: 10, color: colors.goldAccent),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildLogoCenterpiece(l10n),
                      const SizedBox(height: 28),
                      if (_error != null) ...[
                        _buildErrorBanner(_error!),
                        const SizedBox(height: 16),
                      ],
                      _buildFormCard(l10n),
                      const SizedBox(height: 24),
                      _buildSubmitButton(l10n),
                      const SizedBox(height: 16),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              l10n.forgotPassword,
                              style: const TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCenterpiece(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logotameen.jpg',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.shield_rounded, size: 80, color: _accent),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              duration: 700.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 500.ms),
        const SizedBox(height: 16),
        Text(
          l10n.alIttihad,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _accent,
            fontFamily: 'Cairo',
            letterSpacing: 1.2,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 4),
        Text(
          l10n.operatorPortalTitle,
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurfaceVariant,
            fontFamily: 'Cairo',
          ),
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 10),
        Container(
          width: 32,
          height: 2,
          color: colors.goldAccent,
        ).animate().fadeIn(delay: 400.ms).scaleX(begin: 0, end: 1),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.error,
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 400.ms);
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: colors.beigeCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.goldAccent.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    l10n.login,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    l10n.alIttihad,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _PremiumFieldLabel(label: l10n.email),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'example@email.com',
                      icon: Icons.email_outlined,
                    ),
                    validator: (v) =>
                        v!.isEmpty ? l10n.emailRequired : null,
                  ),
                ),
                const SizedBox(height: 16),
                _PremiumFieldLabel(label: l10n.password),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _pwCtrl,
                    obscureText: _obscurePw,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePw
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colors.goldAccent.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePw = !_obscurePw),
                      ),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? l10n.passwordRequired : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: GestureDetector(
          onTap: _loading ? null : _login,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, _dark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: colors.goldAccent.withValues(alpha: 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: _loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.surface,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          l10n.login,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.surface,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack)
        .shimmer(delay: 1400.ms, duration: 1800.ms);
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    final colors = context.colors;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colors.beigeCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: Icon(icon, color: colors.goldAccent, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.warmDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.warmDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }
}

class _PremiumFieldLabel extends StatelessWidget {
  const _PremiumFieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.darkText,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
