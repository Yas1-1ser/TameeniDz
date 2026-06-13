import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import '../../../../../core/providers/service_providers.dart';

class EmailVerificationModal extends ConsumerStatefulWidget {
  const EmailVerificationModal({super.key});

  @override
  ConsumerState<EmailVerificationModal> createState() =>
      _EmailVerificationModalState();
}

class _EmailVerificationModalState
    extends ConsumerState<EmailVerificationModal> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _codeSent
                ? AppLocalizations.of(context)!.enterCode
                : AppLocalizations.of(context)!.confirmEmail,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _codeSent
                ? '${AppLocalizations.of(context)!.codeSentTo} ${_emailController.text}'
                : AppLocalizations.of(context)!.enterEmailHint,
            style: TextStyle(color: context.colors.slate500, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (!_codeSent)
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            )
          else
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.verificationCode,
                hintText: '123456',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        _codeSent
                            ? AppLocalizations.of(context)!.confirm
                            : AppLocalizations.of(context)!.sendCode,
                        style: TextStyle(
                          color: context.colors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _sendCode() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _codeSent = true;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;

    if (user != null) {
      await supabase
          .from('users')
          .update({
            'email': _emailController.text.trim(),
            'email_verified': true,
          })
          .eq('id', user.id);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.emailVerifiedSuccess),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}
