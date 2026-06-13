import 'dart:math';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/providers/service_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/shared/widgets/responsive_layout.dart';
import '../../splash/widgets/floating_particles.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';

/// Highly stylized premium Client Login Screen.
/// Optimized with ValueNotifiers and RepaintBoundaries to eliminate input lag.
class ClientLoginScreen extends ConsumerStatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  ConsumerState<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends ConsumerState<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // PERFORMANCE: Use ValueNotifiers to isolate rebuilds during UI interactions
  final ValueNotifier<bool> _isEmailMode = ValueNotifier(true);
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _isEmailMode.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isEmailMode.value) {
      await _loginWithEmail();
    } else {
      await _sendOtp();
    }
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (response.user != null && mounted) {
        context.go(AppRoutes.home);
      }
    } on AuthException catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() => _errorMessage = AuthExceptionHandler.translate(e, locale));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = AppLocalizations.of(context)!.unexpectedError,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final phone = _phoneCtrl.text.trim();
    final cleanedPhone = phone.replaceFirst(RegExp(r'^0'), '');
    final formattedPhone = '+213$cleanedPhone';

    // DUMMY NAVIGATION FOR DEMO PURPOSES
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _loading = false);
      context.push(
        AppRoutes.otpVerify,
        extra: {
          'verificationId': 'dummy-id-for-testing',
          'phoneNumber': formattedPhone,
          'isRegistration': false,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Cache l10n
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldAccent.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
              size: 18,
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.roleClient);
            }
          },
        ),
        actions: const [
          LanguagePickerButton(),
          SizedBox(width: 16),
        ],
      ),
      body: PageEntryAnimation(child: Stack(
        children: [
          // ── Radial gradient background ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFFFFFDF9),
                    Color(0xFFF9F6F0),
                    Color(0xFFF2ECE0),
                  ],
                ),
              ),
            ),
          ),
          // ── Floating gold particles ──
          const Positioned.fill(
            child: FloatingParticles(
              count: 10,
              color: AppColors.goldAccent,
            ),
          ),
          SafeArea(
            child: Center(
              child: ResponsiveWidthConstraint(
                maxWidth: 400,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildLogoCenterpiece(screenWidth),
                      const SizedBox(height: 28),
                      // PERFORMANCE: Isolated Form Card
                      RepaintBoundary(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isEmailMode,
                          builder: (context, isEmail, _) {
                            return _buildFormCard(l10n, isEmail);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(l10n),
                      const SizedBox(height: 16),

                      ValueListenableBuilder<bool>(
                        valueListenable: _isEmailMode,
                        builder: (context, isEmail, _) {
                          if (!isEmail) return const SizedBox.shrink();
                          return TextButton(
                            onPressed: () => context.push(AppRoutes.forgotPassword),
                            child: Text(
                              l10n.forgotPassword,
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms);
                        },
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              l10n.dontHaveAccount,
                              style: const TextStyle(
                                color: AppColors.midBrown,
                                fontSize: 13,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.registerStep1),
                              child: Text(
                                l10n.createNewAccount,
                                style: const TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  // ── Logo Centerpiece ──
  Widget _buildLogoCenterpiece(double screenWidth) {
    final diameter = min(screenWidth * 0.45, 160.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surface,
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.45),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipOval(
            child: Image.asset(
              'assets/images/logotameen.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryContainer,
                child: const Icon(
                  Icons.shield_rounded,
                  size: 60,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
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
        const Text(
          'تأميني إيليت',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
            fontFamily: 'Cairo',
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 2,
          color: AppColors.goldAccent,
        ).animate().fadeIn(delay: 400.ms).scaleX(begin: 0, end: 1),
      ],
    );
  }

  // ── Form Card ──
  Widget _buildFormCard(AppLocalizations l10n, bool isEmailMode) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.beigeCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.25),
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
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  isEmailMode ? l10n.loginSubtitle : l10n.enterPhone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.midBrown,
                    height: 1.4,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                _ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              if (isEmailMode) ...[
                const _PremiumFieldLabel(label: 'البريد الإلكتروني'),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _buildTextField(
                    controller: _emailCtrl,
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.enterEmail;
                      if (!v.contains('@')) return l10n.invalidEmail;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const _PremiumFieldLabel(label: 'كلمة المرور'),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _obscurePassword,
                    builder: (context, obscure, _) {
                      return _buildTextField(
                        controller: _passwordCtrl,
                        hint: '••••••••',
                        obscureText: obscure,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.goldAccent.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          onPressed: () => _obscurePassword.value = !obscure,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.passwordHint;
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                const _PremiumFieldLabel(label: 'رقم الهاتف'),
                SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '0XXXXXXXXX',
                      filled: true,
                      fillColor: context.colors.beigeCard,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.colors.warmDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.colors.warmDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: AppColors.goldAccent,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '+213',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.colors.darkText,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 22,
                              color: AppColors.goldAccent.withValues(alpha: 0.30),
                            ),
                          ],
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.enterPhone;
                      var cleaned = v.replaceAll(RegExp(r'\D'), '');
                      if (cleaned.startsWith('213')) {
                        cleaned = cleaned.substring(3);
                      }
                      if (cleaned.length != 9 && cleaned.length != 10) {
                        return l10n.invalidPhoneNumber;
                      }
                      if (cleaned.length == 10 &&
                          !RegExp(r'^0[567]').hasMatch(cleaned)) {
                        return l10n.invalidPhoneNumber;
                      }
                      if (cleaned.length == 9 &&
                          !RegExp(r'^[567]').hasMatch(cleaned)) {
                        return l10n.invalidPhoneNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    _isEmailMode.value = !isEmailMode;
                    setState(() => _errorMessage = null);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEmailMode ? l10n.usePhone : l10n.useEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared text field builder ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: context.colors.beigeCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.goldAccent, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.warmDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.warmDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // ── Submit Button ──
  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: GestureDetector(
        onTap: _loading ? null : _handleLogin,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, Color(0xFF247E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.35),
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
                      color: context.colors.surface,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isEmailMode,
                        builder: (context, isEmail, _) {
                          return Icon(
                            isEmail
                                ? Icons.login_rounded
                                : Icons.phone_outlined,
                            size: 18,
                            color: context.colors.surface,
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isEmailMode,
                        builder: (context, isEmail, _) {
                          return Text(
                            isEmail ? l10n.login : l10n.sendOtp,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.colors.surface,
                              fontFamily: 'Cairo',
                            ),
                          );
                        },
                      ),
                    ],
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
}

// ── Private Widgets ──────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'Cairo'),
            ),
          ),
        ],
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
