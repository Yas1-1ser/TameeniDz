import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../shared/widgets/portal_layout.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String? policyId;
  const PaymentScreen({super.key, this.policyId});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCard = 'dahabiya';
  final TextEditingController _amountController = TextEditingController(
    text: '8,500',
  );
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.homeNav, '/client'),
      (Icons.compare_arrows_rounded, l10n.plansNav, '/client/plans'),
      (Icons.history_edu_rounded, l10n.legal, '/client/legal'),
      (Icons.headset_mic_rounded, l10n.support, '/client/support'),
      (Icons.settings_rounded, l10n.settings, '/client/settings'),
    ];

    return PortalLayout(
      selectedIndex: 0,
      menuItems: menuItems,
      portalTitle: l10n.electronicPayment,
      portalSubtitle: l10n.shariaInsurance,
      accentColor: colors.primary,
      showBackButton: true,
      fallbackRoute: '/client',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button handled by PortalLayout AppBar
              const SizedBox(height: 16),

              Text(
                l10n.electronicPayment,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.choosePaymentMethod,
                style: TextStyle(fontSize: 14, color: colors.slate500),
              ),
              const SizedBox(height: 32),

              _buildCardIllustration(),
              const SizedBox(height: 32),

              _buildCardSelection(colors, l10n),
              const SizedBox(height: 32),

              _buildAmountInput(colors, l10n),
              const SizedBox(height: 32),

              _buildCardForm(colors, l10n),
              const SizedBox(height: 32),

              _buildSecurityInfo(colors, l10n),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Perform the actual database insert
                      await _processSubscription(context, l10n);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.payNow,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill amount if provided from previous screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GoRouterState.of(context).extra is double) {
        final extraAmount = GoRouterState.of(context).extra as double;
        _amountController.text = NumberFormat.decimalPattern().format(
          extraAmount,
        );
      }
    });
  }

  Future<void> _processSubscription(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final authUser = ref.read(supabaseProvider).auth.currentUser;
    if (authUser == null) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final client = ref.read(supabaseProvider);

      // Parse amount from controller (handling commas if present)
      final amountStr = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountStr) ?? 8500.0;

      if (widget.policyId != null && widget.policyId!.isNotEmpty) {
        // SCENARIO A: Paying for an existing accepted policy
        await client
            .from('policies')
            .update({
              'paid_at': DateTime.now().toIso8601String(),
              'receipt_number': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
            })
            .eq('id', widget.policyId!);
      } else {
        // SCENARIO B: Creating a new direct subscription (legacy flow)
        final planData =
            await client
                .from('plans')
                .select('id, operator_id, premium_amount')
                .limit(1)
                .maybeSingle();

        if (planData == null) {
          throw Exception(
            'No active insurance plans found in database. Please contact support.',
          );
        }

        final planId = planData['id'];
        final operatorId = planData['operator_id'];

        await client.from('policies').insert({
          'client_id': authUser.id,
          'plan_id': planId,
          'operator_id': operatorId,
          'status': 'pending',
          'amount': amount,
          'submitted_at': DateTime.now().toIso8601String(),
          'plan_name': 'Comprehensive Auto Takaful',
        });
      }

      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        _showSuccessDialog(context, l10n);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Payment Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accepted,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.paymentSuccessTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.paymentSuccessSubtitle(
                    _amountController.text,
                    _selectedCard == 'dahabiya' ? 'Edahabia' : 'CIB',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.slate500),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/client'),
                    child: Text(l10n.backToDashboard),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ── Input Formatters ──────────────────────────────────────────────────────

  final _cardNumberFormatter = _CardNumberInputFormatter();
  final _expiryDateFormatter = _ExpiryDateInputFormatter();

  Widget _buildCardForm(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel(l10n.cardHolder),
          const SizedBox(height: 8),
          _buildTextField(
            _cardHolderController,
            'Full Name',
            Icons.person_outline,
            validator:
                (v) => (v == null || v.isEmpty) ? l10n.enterCardHolder : null,
          ),
          const SizedBox(height: 16),
          _buildInputLabel(l10n.cardNumber),
          const SizedBox(height: 8),
          _buildTextField(
            _cardNumberController,
            '**** **** **** ****',
            Icons.credit_card,
            formatters: [
              _cardNumberFormatter,
              LengthLimitingTextInputFormatter(19),
            ],
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enterCardNumber;
              if (v.replaceAll(' ', '').length < 16) {
                return l10n.invalidCardNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(l10n.expiryDate),
                    const SizedBox(height: 8),
                    _buildTextField(
                      _expiryController,
                      'MM/YY',
                      Icons.calendar_today_outlined,
                      formatters: [
                        _expiryDateFormatter,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.enterExpiryDate;
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v)) {
                          return l10n.invalidExpiryDate;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(l10n.cvv),
                    const SizedBox(height: 8),
                    _buildTextField(
                      _cvvController,
                      '***',
                      Icons.lock_outline,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.enterCvv;
                        if (v.length < 3) return l10n.invalidCvv;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.colors.darkText,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      inputFormatters: formatters,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: context.colors.slate400),
        filled: true,
        fillColor: context.colors.slate100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.slate200),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildCardIllustration() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(-20, 10),
              child: Transform.rotate(
                angle: -0.1,
                child: _miniCard(AppColors.goldAccent, 'Edahabia'),
              ),
            ),
            Transform.translate(
              offset: const Offset(20, -10),
              child: Transform.rotate(
                angle: 0.1,
                child: _miniCard(Colors.blue.shade800, 'CIB'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(Color color, String text) {
    return Container(
      width: 220,
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.wifi, color: Colors.white, size: 20),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '**** **** **** 8824',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSelection(AppColorsExtension colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _selectionItem(
            l10n.edahabiaCard,
            'dahabiya',
            Icons.credit_card_rounded,
            AppColors.goldAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _selectionItem(
            'CIB',
            'cib',
            Icons.payment_rounded,
            Colors.blue.shade800,
          ),
        ),
      ],
    );
  }

  Widget _selectionItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCard == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCard = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : context.colors.slate200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : context.colors.slate500,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : context.colors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(AppColorsExtension colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(l10n.amountToPay),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
          decoration: InputDecoration(
            suffixText: l10n.dzd,
            filled: true,
            fillColor: colors.slate100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.securePaymentNotice,
              style: TextStyle(color: colors.slate500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Input Formatters ──────────────────────────────────────────────────

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
