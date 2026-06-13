import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import '../../../../../generated/l10n/app_localizations.dart';

enum _StepState { completed, active, upcoming }

/// Redesigned client Registration Step 1 Screen.
/// Uses the brand's Luxury Beige + Gold design system and preserves all business logic.
class Step1PersonalInfo extends ConsumerStatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  ConsumerState<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends ConsumerState<Step1PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedWilaya;

  final List<String> _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra',
    'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret',
    'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda', 'Skikda',
    'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem',
    'M\'Sila', 'Mascara', 'Ouargla', 'Oran', 'El Bayadh', 'Illizi',
    'Bordj Bou Arreridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt',
    'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla',
    'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane',
  ];

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.enterName;
    if (value.length < 3) return l10n.nameTooShort;
    return null;
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.enterPhone;
    var cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('213')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.length != 9 && cleaned.length != 10) {
      return l10n.invalidPhoneNumber;
    }
    if (cleaned.length == 10 && !RegExp(r'^0[567]').hasMatch(cleaned)) {
      return l10n.invalidPhoneNumber;
    }
    if (cleaned.length == 9 && !RegExp(r'^[567]').hasMatch(cleaned)) {
      return l10n.invalidPhoneNumber;
    }
    return null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.enterEmail;
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) return l10n.invalidEmail;
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final phone = _normalizePhone(_phoneController.text.trim());

      try {
        final client = Supabase.instance.client;
        
        // 1. Check if phone is already taken (using 'users' table as per auth service)
        final phoneCheck = await client
            .from('users')
            .select('id')
            .eq('phone_number', phone)
            .maybeSingle();
            
        if (phoneCheck != null) {
          setState(() {
            _isLoading = false;
            final lang = Localizations.localeOf(context).languageCode;
            _error = AuthExceptionHandler.translateCode('auth_phone_taken', lang);
          });
          return;
        }

        // 2. Check if email is already taken
        final emailCheck = await client
            .from('users')
            .select('id')
            .eq('email', _emailController.text.trim().toLowerCase())
            .maybeSingle();

        if (emailCheck != null) {
          setState(() {
            _isLoading = false;
            final lang = Localizations.localeOf(context).languageCode;
            _error = AuthExceptionHandler.translateCode('auth_email_taken', lang);
          });
          return;
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        setState(() {
          _isLoading = false;
          final lang = Localizations.localeOf(context).languageCode;
          _error = AuthExceptionHandler.handle(e, lang);
        });
      }

      if (mounted) {
        setState(() => _isLoading = false);
        context.push(
          '/client/auth/otp',
          extra: {
            'verificationId': 'dummy-id-for-testing',
            'phoneNumber': phone,
            'isRegistration': true,
            'email': _emailController.text.trim(),
            'fullName': _nameController.text.trim(),
            'nin': '',
            'ccpNumber': '',
            'dob': _dobController.text.trim(),
            'wilaya': _selectedWilaya,
          },
        );
      }
    }
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('213')) return '+$digits';
    return '+213${digits.replaceFirst(RegExp(r'^0'), '')}';
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
              context.go('/role/client');
            }
          },
        ),
        title: Text(
          l10n.register,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Horizontal Stepper Progress Tracker - Standardized 1-2-3
                _buildStepper(l10n),
                const SizedBox(height: 28),

                // Form Card Container
                Container(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title inside card
                        Text(
                          l10n.personalInfo,
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

                        // Full Name Input
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration(
                            labelText: l10n.fullName,
                            prefixIcon: Icons.person_outline,
                            hintText: l10n.fullNameHint,
                          ),
                          validator: (v) => _validateName(v, l10n),
                        ),
                         const SizedBox(height: 16),

                        // Phone Number Input
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          decoration: _buildInputDecoration(
                            labelText: l10n.phoneLabel,
                            prefixIcon: Icons.phone_outlined,
                            hintText: '05XX XX XX XX',
                          ),
                          validator: (v) => _validatePhone(v, l10n),
                        ),
                        const SizedBox(height: 16),

                        // Email Address Input
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          decoration: _buildInputDecoration(
                            labelText: l10n.emailLabel,
                            prefixIcon: Icons.email_outlined,
                            hintText: 'example@domain.com',
                          ),
                          validator: (v) => _validateEmail(v, l10n),
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth Input
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            labelText: l10n.dobLabel,
                            prefixIcon: Icons.calendar_today_outlined,
                            hintText: l10n.dobHint,
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primaryGreen,
                                      onPrimary: Colors.white,
                                      onSurface: context.colors.darkText,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setState(() {
                                _dobController.text =
                                    "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Wilaya Dropdown
                        Text(
                          l10n.wilaya,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.slate500,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedWilaya,
                          decoration: InputDecoration(
                            hintText: l10n.selectWilaya,
                            hintStyle: TextStyle(
                              color: context.colors.slate400,
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: context.colors.beigeCard,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: context.colors.warmDivider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: context.colors.warmDivider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryGreen),
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.goldAccent,
                          ),
                          items: _wilayas.map((String wilaya) {
                            return DropdownMenuItem<String>(
                              value: wilaya,
                              child: Text(
                                wilaya,
                                style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedWilaya = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Error Card
                if (_error != null) ...[
                  _buildErrorCard(),
                  const SizedBox(height: 20),
                ],

                // Submit Button (Next)
                GestureDetector(
                  onTap: _isLoading ? null : _submitForm,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGreen, Color(0xFF247E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: AppColors.goldAccent.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.next,
                                style: TextStyle(
                                  color: context.colors.surface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(number: '1', title: l10n.information, state: _StepState.active),
        _buildStepDivider(isGold: false),
        _buildStepNode(number: '2', title: l10n.verification, state: _StepState.upcoming),
        _buildStepDivider(isGold: false),
        _buildStepNode(number: '3', title: l10n.documents, state: _StepState.upcoming),
      ],
    );
  }

  Widget _buildStepDivider({bool isGold = false}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isGold
            ? AppColors.goldAccent.withValues(alpha: 0.60)
            : context.colors.warmDivider,
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
        circleColor = AppColors.goldAccent;
        borderColor = AppColors.goldAccent;
        content = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
        textColor = AppColors.goldAccent;
        break;
      case _StepState.active:
        circleColor = Colors.white;
        borderColor = AppColors.goldAccent;
        content = Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.goldAccent,
          ),
        );
        textColor = AppColors.goldAccent;
        break;
      case _StepState.upcoming:
        circleColor = context.colors.beigeCard;
        borderColor = AppColors.goldAccent.withValues(alpha: 0.25);
        content = Text(
          number,
          style: TextStyle(
            color: AppColors.goldAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
              fontSize: 11,
              fontWeight: state == _StepState.active ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rejected.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rejected.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.rejected),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.rejected, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
