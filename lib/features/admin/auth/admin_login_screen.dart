import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../shared/widgets/responsive_layout.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          color: ResponsiveLayout.isMobile(context) ? AppColors.onSurface : Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Row(children: [
        // ── Left decorative panel ─────────────────────────────
        if (!ResponsiveLayout.isMobile(context))
          Expanded(
            flex: 5,
            child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, Color(0xFF0A3D22)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8),
                    itemBuilder: (_, __) =>
                    const Icon(Icons.shield, color: Colors.white),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.adminPortalTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    const Text('Tameeni Elite',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            letterSpacing: 4)),
                    const SizedBox(height: 40),
                    Text(
                      l10n.adminPortalSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.7),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              color: AppColors.primaryContainer, size: 16),
                          SizedBox(width: 8),
                          Text(l10n.activeAudited,
                              style: TextStyle(
                                  color: AppColors.primaryContainer,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),

        // ── Right login panel ─────────────────────────────────
        Expanded(
          flex: 7,
          child: Container(
            color: AppColors.surfaceContainerLowest,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // _buildStepIndicator(l10n),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _step == 0
                            ? _buildCredentialsStep(l10n)
                            : _step == 1
                            ? _buildBiometricStep(l10n)
                            : _buildOtpStep(l10n),
                      ),
                      if (_error != null) ...[
                        SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        )]),
    );
  }

  // ── Step indicator ──────────────────────────────────────────

/*
  Widget _buildStepIndicator(AppLocalizations l10n) {
    final steps = [l10n.loginAction, l10n.biometricVerification, l10n.otpVerification];
    return Row(
      children: steps.asMap().entries.map((e) {
        final done = e.key < _step;
        final active = e.key == _step;
        return Expanded(
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.accepted
                    : active
                    ? AppColors.primaryGreen
                    : AppColors.outlineVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text('${e.key + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            if (e.key < 2)
              Expanded(
                child: Container(
                  height: 2,
                  color: done ? AppColors.accepted : AppColors.outlineVariant,
                ),
              ),
          ]),
        );
      }).toList(),
    );
  }
*/

  // ── Step 1: email + password ────────────────────────────────

  Widget _buildCredentialsStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.generalManager,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface)),
        SizedBox(height: 6),
        Text(l10n.adminLoginPrompt,
            style: TextStyle(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 28),

        // Email
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.emailLabel,
            prefixIcon: const Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        TextField(
          controller: _pwCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: l10n.adminPasswordLabel,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : () => _verifyCredentials(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : Text(l10n.loginAction,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // Validate credentials + check admin role, then advance to step 2
  Future<void> _verifyCredentials(AppLocalizations l10n) async {
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.credentialError);
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final role = res.user?.userMetadata?['role'] as String?;
      if (role != 'admin') {
        await Supabase.instance.client.auth.signOut();
        setState(() {
          _loading = false;
          _error = l10n.notAdminError;
        });
        return;
      }

      // Credentials valid + admin role confirmed
      // Skip multi-step verification for easier access as requested
      if (mounted) context.go('/admin/dashboard');

    } on AuthException catch (e) {
      setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      setState(() { _loading = false; _error = l10n.unexpectedError; });
    }
  }

  // ── Step 2: biometric confirmation (UI only) ────────────────
  // Real biometric auth requires local_auth package.
  // This step simulates confirmation — replace onTap body
  // with LocalAuthentication().authenticate() when ready.

  Widget _buildBiometricStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(1),
      children: [
        Text(l10n.biometricVerification,
            style:
            const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(l10n.biometricStepSubtitle,
            style: TextStyle(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 36),
        GestureDetector(
          onTap: _loading
              ? null
              : () async {
            setState(() { _loading = true; _error = null; });
            // TODO: replace with real local_auth check:
            // final localAuth = LocalAuthentication();
            // final ok = await localAuth.authenticate(
            //   localizedReason: l10n.verifyIdentityPrompt);
            // if (!ok) { setState(() { _loading=false; _error=l10n.verificationFailed; }); return; }
            await Future.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              setState(() {
                _loading = false;
                _biometricDone = true;
              });
              await Future.delayed(const Duration(milliseconds: 400));
              if (mounted) setState(() => _step = 2);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _biometricDone
                  ? AppColors.accepted.withValues(alpha: 0.1)
                  : AppColors.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: _biometricDone
                    ? AppColors.accepted
                    : AppColors.primaryGreen,
                width: 2,
              ),
            ),
            child: _loading
                ? const Padding(
                padding: EdgeInsets.all(30),
                child:
                CircularProgressIndicator(strokeWidth: 2))
                : Icon(
              _biometricDone
                  ? Icons.check_circle
                  : Icons.fingerprint,
              size: 52,
              color: _biometricDone
                  ? AppColors.accepted
                  : AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _biometricDone ? l10n.verifiedSuccess : l10n.pressToScan,
          style: TextStyle(
            color: _biometricDone
                ? AppColors.accepted
                : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ── Step 3: OTP via email ───────────────────────────────────
  // Admin is already signed in (step 1). This OTP is a second
  // factor sent to their email via a Supabase Edge Function or
  // magic-link resend. For now we verify via verifyOTP email type.

  Widget _buildOtpStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(2),
      children: [
        Text(l10n.otpVerification,
            style:
            const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(l10n.otpStepSubtitle,
            style: TextStyle(color: AppColors.onSurfaceVariant)),
        SizedBox(height: 4),
        Text(
          '${l10n.otpSentTo} ${_emailCtrl.text.trim()}',
          style:
          TextStyle(fontSize: 12, color: AppColors.slate500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // 6-digit OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Container(
              width: 44,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _otpCtrl[i].text.isEmpty &&
                      i > 0) {
                    _otpFocus[i - 1].requestFocus();
                  }
                },
                child: TextField(
                  controller: _otpCtrl[i],
                  focusNode: _otpFocus[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      border: InputBorder.none, counterText: ''),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _otpFocus[i + 1].requestFocus();
                    }
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : () => _verifyOtp(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2)
                : Text(l10n.enterDashboard,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),

        const SizedBox(height: 16),

        // Resend
        TextButton(
          onPressed: _loading ? null : () => _resendOtp(l10n),
          child: Text(l10n.resendOtp,
              style: TextStyle(color: AppColors.primaryGreen)),
        ),
      ],
    );
  }

  Future<void> _verifyOtp(AppLocalizations l10n) async {
    final code = _otpCtrl.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _error = l10n.enterFullCode);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: _emailCtrl.text.trim(),
        token: code,
        type: OtpType.email,
      );
      if (mounted) context.go('/admin/dashboard');
    } on AuthException catch (e) {
      setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = l10n.invalidOtp;
      });
    }
  }

  Future<void> _resendOtp(AppLocalizations l10n) async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.email,
        email: _emailCtrl.text.trim(),
      );
      setState(() => _loading = false);
    } catch (_) {
      setState(() {
        _loading = false;
        _error = l10n.resendFailed;
      });
    }
  }
}
