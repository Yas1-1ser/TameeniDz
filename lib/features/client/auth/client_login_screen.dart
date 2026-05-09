import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../shared/widgets/responsive_layout.dart';

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
  bool _loading = false;
  bool _isEmailMode = true;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isEmailMode) {
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
        context.go('/client');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(
        () => _errorMessage = AppLocalizations.of(context)!.unexpectedError,
      );
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
    // Format Algerian number: +213XXXXXXXXX (remove leading 0 if present)
    final cleanedPhone = phone.replaceFirst(RegExp(r'^0'), '');
    final formattedPhone = '+213$cleanedPhone';

    // DUMMY NAVIGATION TO BYPASS FIREBASE BILLING ERROR
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _loading = false);
      context.push(
        '/client/auth/otp',
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
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.onSurface, size: 24),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/role/client');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ResponsiveWidthConstraint(
                  maxWidth: 500,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.login,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: context.colors.darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isEmailMode
                                ? AppLocalizations.of(context)!.loginSubtitle
                                : AppLocalizations.of(context)!.enterPhone,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.slate500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_errorMessage != null) ...[
                            _ErrorBanner(message: _errorMessage!),
                            const SizedBox(height: 16),
                          ],

                          if (_isEmailMode) ...[
                            // ── Email Field ───────────────────────────
                            _FieldLabel(
                              label: AppLocalizations.of(context)!.email,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'example@email.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.enterEmail;
                                }
                                if (!v.contains('@')) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Password Field ────────────────────────
                            _FieldLabel(
                              label: AppLocalizations.of(context)!.password,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: context.colors.slate500,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.passwordHint;
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            // ── Phone Field ───────────────────────────
                            _FieldLabel(
                              label: AppLocalizations.of(context)!.phoneLabel,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                hintText: '0XXXXXXXXX',
                                prefixIcon: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '+213',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.darkText,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: context.colors.slate200,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.enterPhone;
                                }
                                if (v.length < 9) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.invalidPhoneNumber;
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ── Toggle Login Mode ─────────────────────
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEmailMode = !_isEmailMode;
                                  _errorMessage = null;
                                });
                              },
                              child: Text(
                                _isEmailMode
                                    ? AppLocalizations.of(context)!.usePhone
                                    : AppLocalizations.of(context)!.useEmail,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _handleLogin,
                              icon:
                                  _loading
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.login_rounded,
                                        size: 18,
                                      ),
                              label: Text(
                                _loading
                                    ? (_isEmailMode
                                        ? AppLocalizations.of(
                                          context,
                                        )!.dashboard
                                        : AppLocalizations.of(
                                          context,
                                        )!.sendingOtp)
                                    : (_isEmailMode
                                        ? AppLocalizations.of(context)!.login
                                        : AppLocalizations.of(
                                          context,
                                        )!.sendOtp),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.dontHaveAccount,
                                  style: TextStyle(
                                    color: context.colors.slate500,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      () => context.go('/register/step1'),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.createNewAccount,
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.colors.darkText,
        ),
      ),
    );
  }
}
