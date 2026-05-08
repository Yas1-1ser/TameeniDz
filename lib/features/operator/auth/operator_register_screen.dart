import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../generated/l10n/app_localizations.dart';

class OperatorRegisterScreen extends StatefulWidget {
  final String? preselectedCompany;

  const OperatorRegisterScreen({super.key, this.preselectedCompany});

  @override
  State<OperatorRegisterScreen> createState() => _OperatorRegisterScreenState();
}

class _OperatorRegisterScreenState extends State<OperatorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late String? _selectedCompany;
  bool _obscurePw = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  bool _success = false;

  static final _companies = [
    _CompanyOption(
      id: 'algeria_takaful',
      nameAr: 'الجزائر للتكافل',
      nameEn: 'Algeria Takaful',
      color: AppColors.primaryGreen,
      icon: Icons.shield_rounded,
    ),
    _CompanyOption(
      id: 'al_ittihad',
      nameAr: 'الاتحاد',
      nameEn: 'Al-Ittihad',
      color: AppColors.alIttihadGreen,
      icon: Icons.verified_user_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCompany = widget.preselectedCompany;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _employeeIdCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCompany == null) {
      setState(() => _error = AppLocalizations.of(context)!.selectCompanyFirst);
      return;
    }
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
          'company': _selectedCompany,
          'role': 'operator',
        },
      );

      if (response.user != null) {
        await UserProfileService(client).upsertOperatorProfile(
          user: response.user!,
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          employeeId: _employeeIdCtrl.text.trim(),
          company: _selectedCompany!,
        );
      }

      if (mounted) {
        setState(() {
          _loading = false;
          _success = true;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _loading = false;
        _error = _translate(e.message);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '${AppLocalizations.of(context)!.unexpectedError}: $e';
      });
    }
  }

  String _translate(String msg) {
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return AppLocalizations.of(context)!.alreadyHaveAccount;
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _companies.where((c) => c.id == _selectedCompany).firstOrNull;
    final accentColor = selected?.color ?? AppColors.primaryGreen;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, selected, accentColor, isAr),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _success ? _buildSuccessView(selected, isAr) : _buildForm(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, _CompanyOption? selected, Color accentColor, bool isAr) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: accentColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () => context.go('/role/operator'),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Only show small title when collapsed
            final isCollapsed = constraints.biggest.height <= kToolbarHeight + MediaQuery.of(context).padding.top + 10;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text(
                AppLocalizations.of(context)!.registerNewEmployee,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
            );
          },
        ),
        background: Stack(
          children: [
            // Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Decorative Shield
            Positioned(
              right: -40,
              top: -20,
              child: Icon(
                selected?.icon ?? Icons.business,
                size: 240,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),

            // Centered Branding Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  if (selected != null) ...[
                    // Logo Circle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Icon(selected.icon, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    // Company Name
                    Text(
                      isAr ? selected.nameAr : selected.nameEn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      AppLocalizations.of(context)!.registerNewEmployee,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Color accentColor) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.preselectedCompany == null) ...[
             _SectionLabel(text: l10n.chooseTakafulCompany),
            const SizedBox(height: 12),
            _buildCompanySelector(),
            const SizedBox(height: 24),
          ],

          _SectionLabel(text: l10n.personalInfo),
          const SizedBox(height: 16),
          _buildField(
            controller: _nameCtrl,
            label: l10n.fullNameLabel,
            hint: l10n.fullNameHint,
            icon: Icons.person_outline,
            validator: (v) => (v == null || v.isEmpty) ? l10n.nameRequired : null,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _employeeIdCtrl,
            label: l10n.employeeIdLabel,
            hint: l10n.employeeIdHint,
            icon: Icons.badge_outlined,
            validator: (v) => (v == null || v.isEmpty) ? l10n.employeeIdRequired : null,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _emailCtrl,
            label: l10n.professionalEmailLabel,
            hint: l10n.professionalEmailHint,
            icon: Icons.email_outlined,
            validator: (v) => (v == null || v.isEmpty) ? l10n.enterEmail : null,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 24),
          _SectionLabel(text: l10n.password),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _pwCtrl,
            label: l10n.password,
            obscure: _obscurePw,
            onToggle: () => setState(() => _obscurePw = !_obscurePw),
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmCtrl,
            label: l10n.confirmPassword,
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) => v != _pwCtrl.text ? l10n.passwordsDontMatch : null,
          ),

          const SizedBox(height: 32),
          if (_error != null) _buildErrorCard(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                elevation: 4,
                shadowColor: accentColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _loading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(l10n.registerAction, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          _buildLoginLink(accentColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCompanySelector() {
    return Row(
      children: _companies.map((c) {
        final isSelected = _selectedCompany == c.id;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCompany = c.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? c.color.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? c.color : context.colors.slate200, width: 2),
              ),
              child: Column(
                children: [
                  Icon(c.icon, color: isSelected ? c.color : context.colors.slate400),
                  const SizedBox(height: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? c.nameAr : c.nameEn,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? c.color : context.colors.onSurface),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: onToggle),
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.rejected.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rejected.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.rejected),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.rejected))),
        ],
      ),
    );
  }

  Widget _buildLoginLink(Color accentColor) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: TextButton(
        onPressed: () => context.go(_selectedCompany == 'algeria_takaful' ? '/at/login' : '/ai/login'),
        child: Text(l10n.alreadyHaveAccount, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSuccessView(_CompanyOption? company, bool isAr) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_rounded, color: AppColors.accepted, size: 80),
        const SizedBox(height: 24),
        Text(l10n.accountCreatedSuccess, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          l10n.confirmationEmailSent(isAr ? (company?.nameAr ?? '') : (company?.nameEn ?? '')),
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.onSurfaceVariant),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go(company?.id == 'algeria_takaful' ? '/at/login' : '/ai/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: company?.color ?? AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.goToLogin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface));
  }
}

class _CompanyOption {
  final String id;
  final String nameAr;
  final String nameEn;
  final Color color;
  final IconData icon;
  const _CompanyOption({required this.id, required this.nameAr, required this.nameEn, required this.color, required this.icon});
}
