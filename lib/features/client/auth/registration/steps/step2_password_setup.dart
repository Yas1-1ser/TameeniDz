import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/providers/service_providers.dart';
import '../../../../../core/theme/app_colors_extension.dart';
import '../../../../../generated/l10n/app_localizations.dart';

enum _StepState { completed, active, upcoming }

class Step2PasswordSetup extends ConsumerStatefulWidget {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String ccpNumber;

  const Step2PasswordSetup({
    super.key,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.ccpNumber,
  });

  @override
  ConsumerState<Step2PasswordSetup> createState() => _Step2PasswordSetupState();
}

class _Step2PasswordSetupState extends ConsumerState<Step2PasswordSetup> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
      final response = await Supabase.instance.client.auth.signUp(
        email: widget.email,
        password: _passwordCtrl.text,
        data: {
          'full_name': widget.fullName,
          'phone_number': widget.phoneNumber,
          'ccp_number': widget.ccpNumber,
          'role': 'client',
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        if (response.session != null) {
          await ref
              .read(userProfileServiceProvider)
              .upsertClientProfile(
                user: response.user!,
                fullName: widget.fullName,
                email: widget.email,
                phoneNumber: widget.phoneNumber,
                ccpNumber: widget.ccpNumber,
              );
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
      // Handle the specific 'Error sending confirmation email' or other Auth errors
      String message = e.message;
      if (message.contains('Error sending confirmation email')) {
        message =
            'Email confirmation is required but failed to send. Please contact support or check your Supabase settings.';
      }
      setState(() => _errorMessage = message);
    } catch (e) {
      setState(() => _errorMessage = l10n.unexpectedAuthError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.createPassword,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/register/step1');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 32),
                _buildFormFields(l10n),
                const SizedBox(height: 16),
                if (_successMessage != null) _buildSuccessBanner(),
                if (_successMessage != null) const SizedBox(height: 16),
                if (_errorMessage != null) _buildErrorBanner(),
                const SizedBox(height: 16),
                _buildSubmitButton(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepper(l10n),
        const SizedBox(height: 32),
        Text(
          l10n.createPasswordTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.colors.darkText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.passwordSetupSubtitle,
          style: TextStyle(fontSize: 14, color: context.colors.slate500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.slate200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: context.colors.slate500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fullName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.colors.darkText,
                      ),
                    ),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(number: '3', title: l10n.documents, state: _StepState.upcoming),
        _buildStepDivider(),
        _buildStepNode(number: '2', title: l10n.verification, state: _StepState.active),
        _buildStepDivider(),
        _buildStepNode(number: '1', title: l10n.information, state: _StepState.completed),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 2,
        color: context.colors.slate200,
      ),
    );
  }

  Widget _buildStepNode({
    required String number,
    required String title,
    required _StepState state,
  }) {
    Color circleColor;
    Color borderColor;
    Widget content;
    Color textColor;

    switch (state) {
      case _StepState.completed:
        circleColor = AppColors.primaryGreen;
        borderColor = AppColors.primaryGreen;
        content = const Icon(Icons.check, color: Colors.white, size: 16);
        textColor = AppColors.primaryGreen;
        break;
      case _StepState.active:
        circleColor = Colors.white;
        borderColor = AppColors.primaryGreen;
        content = Text(
          number,
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        );
        textColor = AppColors.primaryGreen;
        break;
      case _StepState.upcoming:
        circleColor = Colors.transparent;
        borderColor = context.colors.slate300;
        content = Text(
          number,
          style: TextStyle(
            color: context.colors.slate400,
            fontWeight: FontWeight.bold,
          ),
        );
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(color: borderColor, width: 2),
            ),
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
              fontSize: 10,
              fontWeight:
                  state == _StepState.active
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(l10n.password),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          validator: (v) => _validatePassword(v, l10n),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: context.colors.slate500,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.colors.slate500,
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildStrengthIndicator(l10n),
        const SizedBox(height: 20),
        _buildLabel(l10n.confirmPassword),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmCtrl,
          obscureText: _obscureConfirm,
          validator: (v) => _validateConfirm(v, l10n),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: context.colors.slate500,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.colors.slate500,
              ),
              onPressed:
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _submit(l10n),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(l10n.createNewAccount),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rejected.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.rejected.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.rejected),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 13, color: AppColors.rejected),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accepted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accepted.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.accepted,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _successMessage!,
              style: const TextStyle(fontSize: 13, color: AppColors.accepted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: context.colors.darkText,
    ),
  );

  Widget _buildStrengthIndicator(AppLocalizations l10n) {
    final password = _passwordCtrl.text;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;

    final colors = [
      AppColors.rejected,
      Colors.orange,
      Colors.amber,
      AppColors.accepted,
    ];
    final labels = [l10n.weak, l10n.fair, l10n.good, l10n.strong];

    if (password.isEmpty) return const SizedBox.shrink();

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
                  color: i <= idx ? colors[idx] : context.colors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.passwordStrength(labels[idx])}',
          style: TextStyle(fontSize: 12, color: colors[idx]),
        ),
      ],
    );
  }
}
