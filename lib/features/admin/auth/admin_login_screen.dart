import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';
import 'package:tameenidz/core/services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _otpKeyFocus = List.generate(6, (_) => FocusNode());

  int _step = 0; // 0=credentials, 1=biometric confirm, 2=OTP
  bool _obscure = true;
  bool _loading = false;
  bool _biometricDone = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    for (final c in _otpCtrl) { c.dispose(); }
    for (final f in _otpFocus) { f.dispose(); }
    for (final f in _otpKeyFocus) { f.dispose(); }
    super.dispose();
  }

  String _stepTitle(AppLocalizations l10n) {
    switch (_step) {
      case 0: return l10n.adminPortal;
      case 1: return l10n.biometricVerification;
      case 2: return l10n.otpVerification;
      default: return '';
    }
  }

  String _stepSubtitle(AppLocalizations l10n) {
    switch (_step) {
      case 0: return l10n.loginAction;
      case 1: return l10n.biometricStepSubtitle;
      case 2: return l10n.otpStepSubtitle;
      default: return '';
    }
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_step) {
      case 0: return _buildCredentialsStep(l10n);
      case 1: return _buildBiometricStep(l10n);
      case 2: return _buildOtpStep(l10n);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: colors.darkText,
          ),
          onPressed: () => context.go('/role'),
        ),
        actions: const [
          LanguagePickerButton(),
          SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PageEntryAnimation(
        child: Stack(children: [
          Positioned(top: -60, right: -60,
              child: Container(width: 200, height: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(color: colors.goldAccent.withValues(alpha: 0.15), width: 1)))),

          SafeArea(child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(children: [
              // Logo circle
              Container(width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surface,
                      border: Border.all(color: colors.goldAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: colors.darkText.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ]),
                  child: ClipOval(child: Image.asset('assets/images/logotameen.jpg', fit: BoxFit.cover))),
              const SizedBox(height: 16),

              Text(l10n.appBrandName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: colors.darkText, fontFamily: 'Cairo')),
              const SizedBox(height: 6),
              Container(width: 40, height: 2.5, decoration: BoxDecoration(
                  color: colors.goldAccent, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 32),

              Container(padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.outlineVariant, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_stepTitle(l10n), style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold, color: colors.darkText, fontFamily: 'Cairo')),
                    Text(_stepSubtitle(l10n), style: TextStyle(fontSize: 12,
                        color: colors.onSurfaceVariant, fontFamily: 'Cairo')),
                    const SizedBox(height: 24),

                    AnimatedSwitcher(duration: const Duration(milliseconds: 280),
                        child: _buildCurrentStep(l10n)),

                    if (_error != null)
                      Container(margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.error.withValues(alpha: 0.3))),
                          child: Row(children: [
                            Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_error!, style: TextStyle(
                                color: colors.error, fontSize: 13, fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
                          ])),
                  ])),

              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) =>
                  AnimatedContainer(duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _step == i ? 24 : 8, height: 8,
                      decoration: BoxDecoration(
                          color: _step == i ? colors.darkText : colors.outlineVariant,
                          borderRadius: BorderRadius.circular(4))))),
            ]),
          ))),
        ]),
      ),
    );
  }

  Widget _buildCredentialsStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: adminFieldDecoration(context, l10n.emailLabel, Icons.mail_outline_rounded),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pwCtrl,
          obscureText: _obscure,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: adminFieldDecoration(context, l10n.adminPasswordLabel, Icons.lock_outline_rounded)
              .copyWith(suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: context.colors.onSurfaceVariant, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure))),
        ),
        const SizedBox(height: 24),
        goldButton(l10n.loginAction, () => _verifyCredentials(l10n), loading: _loading),
      ],
    );
  }

  Future<void> _verifyCredentials(AppLocalizations l10n) async {
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.credentialError);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      final role = res.user?.userMetadata?['role'] as String?;
      if (role != 'admin') {
        await Supabase.instance.client.auth.signOut();
        setState(() { _loading = false; _error = l10n.notAdminError; });
        return;
      }

      // FIX: Wait for AuthService to finish fetching the role from the DB
      // before navigating. Without this, the route guard sees role='guest'
      // and redirects the admin to the client portal instead.
      final authService = AuthService.instance;
      if (!authService.isInitialized || authService.userRole != 'admin') {
        // Poll until the role is resolved (typically <300 ms)
        for (int i = 0; i < 20; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (authService.userRole == 'admin') break;
        }
      }

      if (mounted) context.go(AppRoutes.adminDashboard);
    } on AuthException catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() { _loading = false; _error = AuthExceptionHandler.translate(e, locale); });
      }
    } catch (_) {
      setState(() { _loading = false; _error = l10n.unexpectedError; });
    }
  }

  Widget _buildBiometricStep(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      key: const ValueKey(1),
      children: [
        GestureDetector(
          onTap: _loading ? null : () async {
            setState(() { _loading = true; _error = null; });
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) {
              setState(() { _loading = false; _biometricDone = true; });
              await Future.delayed(const Duration(milliseconds: 400));
              if (mounted) setState(() => _step = 2);
            }
          },
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
                color: colors.surface, shape: BoxShape.circle,
                border: Border.all(color: _biometricDone ? colors.goldAccent : colors.darkText, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (_biometricDone ? colors.goldAccent : colors.darkText).withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
            ),
            child: Icon(
              _biometricDone ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
              color: _biometricDone ? colors.goldAccent : colors.darkText,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _biometricDone ? l10n.verifiedSuccess : l10n.pressToScan,
          style: TextStyle(
            color: _biometricDone ? colors.accepted : colors.onSurfaceVariant,
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      key: const ValueKey(2),
      children: [
        Text(
          '${l10n.otpSentTo} ${_emailCtrl.text.trim()}',
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Container(
              width: 42,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: colors.beigeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant, width: 1.5),
              ),
              child: KeyboardListener(
                focusNode: _otpKeyFocus[i],
                onKeyEvent: (event) {
                  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && _otpCtrl[i].text.isEmpty && i > 0) {
                    _otpFocus[i - 1].requestFocus();
                  }
                },
                child: TextField(
                  controller: _otpCtrl[i],
                  focusNode: _otpFocus[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.darkText),
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                  onChanged: (v) { if (v.isNotEmpty && i < 5) _otpFocus[i + 1].requestFocus(); },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        goldButton(l10n.enterDashboard, () => _verifyOtp(l10n), loading: _loading),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _loading ? null : () => _resendOtp(l10n),
          child: Text(
            l10n.resendOtp,
            style: TextStyle(color: colors.goldAccent, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
        ),
      ],
    );
  }

  Future<void> _verifyOtp(AppLocalizations l10n) async {
    final code = _otpCtrl.map((c) => c.text).join();
    if (code.length < 6) { setState(() => _error = l10n.enterFullCode); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.verifyOTP(email: _emailCtrl.text.trim(), token: code, type: OtpType.email);

      // FIX: Same race condition as _verifyCredentials — wait for AuthService
      // to resolve the role before navigating to the admin dashboard.
      final authService = AuthService.instance;
      if (!authService.isInitialized || authService.userRole != 'admin') {
        for (int i = 0; i < 20; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (authService.userRole == 'admin') break;
        }
      }

      if (mounted) context.go(AppRoutes.adminDashboard);
    } on AuthException catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() { _loading = false; _error = AuthExceptionHandler.translate(e, locale); });
      }
    } catch (_) {
      setState(() { _loading = false; _error = l10n.invalidOtp; });
    }
  }

  Future<void> _resendOtp(AppLocalizations l10n) async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.resend(type: OtpType.email, email: _emailCtrl.text.trim());
      setState(() => _loading = false);
    } catch (_) {
      setState(() { _loading = false; _error = l10n.resendFailed; });
    }
  }
}