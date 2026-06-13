import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/utils/auth_exception_handler.dart';
import '../../../../../core/services/notification_helper.dart';

enum _StepState { completed, active, upcoming }

/// Redesigned client Registration Step 2 Screen.
/// Optimized with RepaintBoundaries and ValueNotifiers to eliminate input lag.
class Step2PasswordSetup extends ConsumerStatefulWidget {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String ccpNumber;
  final String? nin;
  final String? wilaya;
  final String? dob;

  const Step2PasswordSetup({
    super.key,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.ccpNumber,
    this.nin,
    this.wilaya,
    this.dob,
  });

  @override
  ConsumerState<Step2PasswordSetup> createState() => _Step2PasswordSetupState();
}

class _Step2PasswordSetupState extends ConsumerState<Step2PasswordSetup> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // PERFORMANCE: Use ValueNotifiers to avoid full-page rebuilds during interaction
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier(true);
  final ValueNotifier<String> _passwordNotifier = ValueNotifier('');
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    _passwordNotifier.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordHint;
    if (value.length < 8) return l10n.passwordTooShort;
    if (!RegExp(r'[A-Z]').hasMatch(value)) return l10n.passwordNeedUpper;
    if (!RegExp(r'[0-9]').hasMatch(value)) return l10n.passwordNeedNumber;
    return null;
  }

  String? _validateConfirm(String? value, AppLocalizations l10n) {
    if (value != _passwordCtrl.text) return l10n.passwordsDontMatch;
    return null;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: widget.email,
        password: _passwordCtrl.text,
        data: {
          'full_name': widget.fullName,
          'phone_number': widget.phoneNumber,
          'ccp_number': widget.ccpNumber,
          'nin': widget.nin,
          'wilaya': widget.wilaya,
          'dob': widget.dob,
          'role': 'subscriber',
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        try {
          await supabase.from('users').upsert({
            'id': response.user!.id,
            'full_name': widget.fullName,
            'email': widget.email,
            'phone_number': widget.phoneNumber,
            'ccp_number': widget.ccpNumber,
            'nin': widget.nin,
            'wilaya': widget.wilaya,
            'date_of_birth': widget.dob,
            'role': 'client',
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');
        } catch (dbErr) {
          debugPrint('Ignored manual upsert error (handled by trigger): $dbErr');
        }

        // ── Notify admins about new registration (fire-and-forget) ──
        NotificationHelper.notifyAdminNewRegistration(
          clientName: widget.fullName,
          clientEmail: widget.email,
        );

        if (response.session != null) {
          if (mounted) context.go('/register/step3');
        } else {
          setState(() {
            _successMessage = l10n.confirmationEmailSent(l10n.client);
          });
          await Future<void>.delayed(const Duration(seconds: 2));
          if (mounted) context.go('/client/login');
        }
      } else {
        setState(() => _errorMessage = l10n.accountCreateError);
      }
    } on AuthException catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() => _errorMessage = AuthExceptionHandler.translate(e, locale));
      }
    } catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        final code = e.toString().contains('unexpected_failure')
                ? 'database_error' : 'auth_unexpected_error';
        setState(() => _errorMessage = AuthExceptionHandler.translateCode(code, locale));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: AppColors.goldAccent, size: 20),
      suffixIcon: suffixIcon,
      fillColor: context.colors.beigeCard,
      filled: true,
      labelStyle: TextStyle(color: context.colors.slate500, fontFamily: 'Cairo', fontSize: 13),
      hintStyle: TextStyle(color: context.colors.slate400, fontFamily: 'Cairo', fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colors.warmDivider, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colors.warmDivider, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Cache l10n lookup
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: context.colors.darkText,
            size: 22,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/register/step1');
            }
          },
        ),
        title: Text(
          l10n.createPassword,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: context.colors.darkText,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: PageEntryAnimation(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStepper(l10n),
                  const SizedBox(height: 28),

                  // Profile Summary Badge
                  _buildProfileSummary(),
                  const SizedBox(height: 20),

                  // Form Card Container - Wrapped in RepaintBoundary to isolate input lag
                  RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: context.colors.beigeCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.28),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.createPasswordTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: AppColors.goldAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Password Field
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscurePassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _passwordCtrl,
                                obscureText: obscure,
                                textInputAction: TextInputAction.next,
                                validator: (v) => _validatePassword(v, l10n),
                                onChanged: (val) => _passwordNotifier.value = val,
                                decoration: _buildInputDecoration(
                                  labelText: l10n.password,
                                  prefixIcon: Icons.lock_outlined,
                                  hintText: '••••••••',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: context.colors.slate500,
                                    ),
                                    onPressed: () => _obscurePassword.value = !_obscurePassword.value,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // Password Strength Indicator - surgically updated
                          ValueListenableBuilder<String>(
                            valueListenable: _passwordNotifier,
                            builder: (context, password, _) {
                              return _buildStrengthIndicator(password, l10n);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscureConfirm,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _confirmCtrl,
                                obscureText: obscure,
                                textInputAction: TextInputAction.done,
                                validator: (v) => _validateConfirm(v, l10n),
                                decoration: _buildInputDecoration(
                                  labelText: l10n.confirmPassword,
                                  prefixIcon: Icons.lock_outlined,
                                  hintText: '••••••••',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: context.colors.slate500,
                                    ),
                                    onPressed: () => _obscureConfirm.value = !_obscureConfirm.value,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_successMessage != null) ...[
                    _buildBanner(_successMessage!, AppColors.accepted, Icons.check_circle_outline),
                    const SizedBox(height: 16),
                  ],
                  if (_errorMessage != null) ...[
                    _buildBanner(_errorMessage!, AppColors.rejected, Icons.error_outline),
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
                  _buildSubmitButton(l10n),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.beigeCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.20), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.goldAccent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fullName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.colors.darkText, fontFamily: 'Cairo')),
                Text(widget.email, style: TextStyle(fontSize: 12, color: context.colors.slate500, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _submit(l10n),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryGreen, Color(0xFF247E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
                l10n.createNewAccount,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
      ),
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(number: '1', title: l10n.information, state: _StepState.completed),
        _buildStepDivider(isGold: true),
        _buildStepNode(number: '2', title: l10n.verification, state: _StepState.active),
        _buildStepDivider(isGold: false),
        _buildStepNode(number: '3', title: l10n.documents, state: _StepState.upcoming),
      ],
    );
  }

  Widget _buildStepDivider({bool isGold = false}) {
    return Expanded(
      child: Container(height: 2, color: isGold ? AppColors.goldAccent : context.colors.warmDivider),
    );
  }

  Widget _buildStepNode({required String number, required String title, required _StepState state}) {
    Color circleColor;
    Color borderColor;
    Widget content;
    Color textColor;

    switch (state) {
      case _StepState.completed:
        circleColor = AppColors.goldAccent;
        borderColor = AppColors.goldAccent;
        content = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
        textColor = AppColors.goldAccent;
        break;
      case _StepState.active:
        circleColor = Colors.white;
        borderColor = AppColors.goldAccent;
        content = Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.goldAccent));
        textColor = AppColors.goldAccent;
        break;
      case _StepState.upcoming:
        circleColor = context.colors.beigeCard;
        borderColor = AppColors.goldAccent.withValues(alpha: 0.25);
        content = Text(number, style: const TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold, fontSize: 12));
        textColor = context.colors.slate400;
        break;
    }

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor, border: Border.all(color: borderColor, width: 2)),
            alignment: Alignment.center,
            child: content,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: state == _StepState.active ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(String password, AppLocalizations l10n) {
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;

    final colors = [AppColors.rejected, Colors.orange, Colors.amber, AppColors.accepted];
    final labels = [l10n.weak, l10n.fair, l10n.good, l10n.strong];

    final idx = (strength - 1).clamp(0, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= idx ? colors[idx] : context.colors.warmDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.passwordStrength(labels[idx]),
          style: TextStyle(fontSize: 12, color: colors[idx], fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
