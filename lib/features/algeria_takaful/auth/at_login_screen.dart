import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';

class AtLoginScreen extends StatefulWidget {
  const AtLoginScreen({super.key});
  @override
  State<AtLoginScreen> createState() => _AtLoginScreenState();
}

class _AtLoginScreenState extends State<AtLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

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
      if (company != 'algeria_takaful') {
        await Supabase.instance.client.auth.signOut();
        setState(
          () =>
              _error = AppLocalizations.of(context)!.wrongCompanyError(
                AppLocalizations.of(context)!.algeriaTakaful,
              ),
        );
        return;
      }

      if (mounted) context.go('/at/dashboard');
    } on AuthException catch (e) {
      setState(() => _error = _translate(e.message));
    } catch (_) {
      setState(() => _error = AppLocalizations.of(context)!.unexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translate(String msg) {
    if (msg.contains('Invalid login')) {
      return AppLocalizations.of(context)!.wrongPassword;
    }
    if (msg.contains('Email not confirmed')) {
      return AppLocalizations.of(
        context,
      )!.codeExpired; // Use more appropriate key if available
    }
    if (msg.contains('Too many')) {
      return AppLocalizations.of(context)!.tooManyRequests;
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.onSurface, size: 24),
          onPressed: () => context.go('/role/operator'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Company header bar ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: AppColors.primaryContainer,
              child: Text(
                l10n.algeriaTakaful,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.admin_panel_settings_outlined,
                              color: AppColors.primaryGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${l10n.employeePortalSubtitle} — ${l10n.algeriaTakaful}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.loginToSystemPrompt,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Error ───────────────────────────────
                          if (_error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.rejected.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.rejected.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.rejected,
                                ),
                              ),
                            ),
                          ],

                          // ── Email ───────────────────────────────
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              labelText: l10n.emailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
                              hintText: 'employee@algeriatakaful.dz',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l10n.emailRequired;
                              }
                              if (!v.contains('@')) {
                                return l10n.invalidEmailError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ── Password ────────────────────────────
                          TextFormField(
                            controller: _pwCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed:
                                    () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l10n.passwordRequired;
                              }
                              if (v.length < 6) {
                                return l10n.passwordTooShortError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── Login button ────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _loading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                      : Text(
                                        l10n.loginAction,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Register link ────────────────────────
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/at/register'),
                                child: Text(
                                  l10n.createEmployeeAccount,
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.newEmployeeQuestion,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.slate500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          // ── Isolation note ──────────────────────
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.04,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.primaryGreen,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.exclusivePortalNote(
                                      l10n.algeriaTakaful,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryGreen,
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
