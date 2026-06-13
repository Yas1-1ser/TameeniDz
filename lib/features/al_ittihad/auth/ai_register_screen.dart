import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import '../../../core/services/user_profile_service.dart';
import 'package:tameenidz/features/operator/auth/operator_auth_shared.dart';
import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';

class AiRegisterScreen extends StatefulWidget {
  const AiRegisterScreen({super.key});

  @override
  State<AiRegisterScreen> createState() => _AiRegisterScreenState();
}

class _AiRegisterScreenState extends State<AiRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePw = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  bool _success = false;

  static const _accent = AppColors.alIttihadGreen;
  static const _dark = Color(0xFF073D27);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _employeeIdCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      final response = await client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
        data: {
          'full_name': _nameCtrl.text.trim(),
          'employee_id': _employeeIdCtrl.text.trim(),
          'company': 'al_ittihad',
          'role': 'operator',
        },
      );
      if (response.user != null) {
        try {
          await UserProfileService(client).upsertOperatorProfile(
            user: response.user!,
            fullName: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            employeeId: _employeeIdCtrl.text.trim(),
            company: 'al_ittihad',
          );
        } catch (dbErr) {
          debugPrint('Ignored manual upsert error (handled by trigger): $dbErr');
        }
        await client.auth.signOut();
      }
      if (mounted) setState(() { _loading = false; _success = true; });
    } on AuthException catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        setState(() {
          _loading = false;
          _error = AuthExceptionHandler.translate(e, locale);
        });
      }
    } catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        final code = e.toString().contains('unexpected_failure') ? 'database_error' : 'auth_unexpected_error';
        setState(() {
          _loading = false;
          _error = AuthExceptionHandler.translateCode(code, locale);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
              color: context.colors.darkText, size: 16
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
              const BeigeBackground(),
              SafeArea(
                child: _success
                    ? SuccessView(
                        company: operatorCompanies.firstWhere((c) => c.id == 'al_ittihad'),
                        isAr: isAr)
                    : Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildTopSection(isAr),
                          const SizedBox(height: 24),
                          if (_error != null)
                            ErrorBanner(message: _error!)
                                .animate()
                                .shake(duration: 400.ms),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                              child: _buildForm(isAr),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildTopSection(bool isAr) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surface,
            border: Border.all(color: _accent.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/images/logotameen.jpg', fit: BoxFit.contain),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
            begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        const SizedBox(height: 12),
        const Text(
          'الجزائر المتحدة',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _accent,
            fontFamily: 'Cairo',
          ),
        ).animate().fadeIn(delay: 150.ms),
        const Text(
          'بوابة المشغّل',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.midBrown,
            fontFamily: 'Cairo',
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildForm(bool isAr) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
              color: _accent.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(
                label: 'إنشاء حساب جديد - الجزائر المتحدة',
                icon: Icons.person_add_alt_1_rounded,
                accent: _accent),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: buildInputDecoration(
                context: context,
                label: 'الاسم الكامل',
                icon: Icons.badge_outlined,
                accent: _accent,
              ),
              validator: (v) =>
                  v!.isEmpty ? 'الرجاء إدخال الاسم الكامل' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: buildInputDecoration(
                context: context,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                accent: _accent,
              ),
              validator: (v) =>
                  v!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _employeeIdCtrl,
              decoration: buildInputDecoration(
                context: context,
                label: 'رقم التعريف الوظيفي',
                icon: Icons.assignment_ind_outlined,
                accent: _accent,
              ),
              validator: (v) => v!.isEmpty ? 'الرجاء إدخال رقم التعريف' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pwCtrl,
              obscureText: _obscurePw,
              decoration: buildInputDecoration(
                context: context,
                label: 'كلمة المرور',
                icon: Icons.lock_outline_rounded,
                accent: _accent,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePw
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: context.colors.slate400,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePw = !_obscurePw),
                ),
              ),
              validator: (v) => v!.isEmpty
                  ? 'يرجى إدخال كلمة المرور'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: buildInputDecoration(
                context: context,
                label: 'تأكيد كلمة المرور',
                icon: Icons.lock_reset_rounded,
                accent: _accent,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: context.colors.slate400,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v!.isEmpty) return 'يرجى تأكيد كلمة المرور';
                if (v != _pwCtrl.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            GradientCta(
              label: 'إنشاء الحساب',
              icon: Icons.how_to_reg_rounded,
              loading: _loading,
              accent: _accent,
              dark: _dark,
              onTap: _register,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'لديك حساب بالفعل؟ ',
                  style: TextStyle(fontSize: 13, color: AppColors.midBrown),
                ),
                GestureDetector(
                  onTap: () => context.go('/ai/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
