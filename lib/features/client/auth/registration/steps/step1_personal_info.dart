import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors_extension.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';

enum _StepState { completed, active, upcoming }

class Step1PersonalInfo extends ConsumerStatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  ConsumerState<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends ConsumerState<Step1PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ninController = TextEditingController();
  final _ccpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedWilaya;

  final List<String> _wilayas = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    'M\'Sila',
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arreridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane',
  ];

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _ninController.dispose();
    _ccpController.dispose();
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
    if (value.length < 10) return l10n.invalidPhoneNumber;
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

      // Check if phone or email is already taken
      try {
        final client = Supabase.instance.client;
        
        // 1. Check if user exists in our profiles table (phone check)
        final phoneCheck = await client
            .from('profiles')
            .select('id')
            .eq('phone_number', phone)
            .maybeSingle();
            
        if (phoneCheck != null) {
          setState(() {
            _isLoading = false;
            _error = AppLocalizations.of(context)!.phoneNumberAlreadyTaken;
          });
          return;
        }

        // 2. Check email
        final emailCheck = await client
            .from('profiles')
            .select('id')
            .eq('email', _emailController.text.trim())
            .maybeSingle();

        if (emailCheck != null) {
          setState(() {
            _isLoading = false;
            _error = AppLocalizations.of(context)!.alreadyHaveAccount;
          });
          return;
        }

        // DUMMY NAVIGATION TO BYPASS FIREBASE BILLING ERROR
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = '${AppLocalizations.of(context)!.unexpectedError}: $e';
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
            'nin': _ninController.text.trim(),
            'ccpNumber': _ccpController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.personalInfo,
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
              context.go('/role/client');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStepper(l10n),
              const SizedBox(height: 32),
              _buildFormCard(l10n),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(number: '3', title: l10n.documents, state: _StepState.upcoming),
        _buildStepDivider(),
        _buildStepNode(number: '2', title: l10n.verification, state: _StepState.upcoming),
        _buildStepDivider(),
        _buildStepNode(number: '1', title: l10n.information, state: _StepState.active),
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

  Widget _buildFormCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: l10n.localeName == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: l10n.localeName == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.personalInfo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 60,
                    height: 3,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _nameController,
              label: l10n.fullName,
              hint: l10n.fullNameHint,
              validator: (v) => _validateName(v, l10n),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _ninController,
              label: l10n.ninLabel,
              hint: l10n.ninHint,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _ccpController,
              label: l10n.ccpLabel,
              hint: l10n.ccpHint,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _phoneController,
              label: l10n.phoneLabel,
              hint: '05XX XX XX XX',
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              validator: (v) => _validatePhone(v, l10n),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _emailController,
              label: l10n.emailLabel,
              hint: 'example@domain.com',
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              validator: (v) => _validateEmail(v, l10n),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _dobController,
              label: l10n.dobLabel,
              hint: l10n.dobHint,
              suffixIcon: Icons.calendar_today_outlined,
              readOnly: true,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.wilaya,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedWilaya,
                  decoration: InputDecoration(
                    hintText: l10n.selectWilaya,
                    hintStyle: TextStyle(
                      color: context.colors.slate400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: context.colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.colors.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.colors.slate200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.colors.slate500,
                  ),
                  items:
                      _wilayas.map((String wilaya) {
                        return DropdownMenuItem<String>(
                          value: wilaya,
                          child: Text(
                            wilaya,
                            style: const TextStyle(fontSize: 14),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.slate500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textDirection: textDirection,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.slate400, fontSize: 14),
            filled: true,
            fillColor: context.colors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen),
            ),
            suffixIcon:
                suffixIcon != null
                    ? Icon(suffixIcon, color: context.colors.darkText, size: 20)
                    : null,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _submitForm,
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
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
              style: const TextStyle(color: AppColors.rejected, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
