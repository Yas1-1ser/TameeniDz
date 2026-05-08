import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/service_providers.dart';

class EmailVerificationModal extends ConsumerStatefulWidget {
  const EmailVerificationModal({super.key});

  @override
  ConsumerState<EmailVerificationModal> createState() =>
      _EmailVerificationModalState();
}

class _EmailVerificationModalState extends ConsumerState<EmailVerificationModal> {
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
    final l10n = AppLocalizations.of(context)!;
    
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
            _codeSent ? l10n.enterCode : l10n.confirmEmail,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _codeSent
                ? '${l10n.codeSentTo} ${_emailController.text}'
                : l10n.enterEmailHint,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (!_codeSent)
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            )
          else
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: l10n.verificationCode,
                hintText: '123456',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _codeSent ? l10n.confirm : l10n.sendCode,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
      await supabase.from('users').update({
        'email': _emailController.text.trim(),
        'email_verified': true,
      }).eq('id', user.id);
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

