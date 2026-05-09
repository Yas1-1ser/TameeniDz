import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
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
  final _screenshotController = ScreenshotController();
  String _selectedCard = 'dahabiya';
  final TextEditingController _amountController = TextEditingController(
    text: '8,500',
  );
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  PlatformFile? _receiptPhoto;
  bool _isUploading = false;

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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),
                  _buildReceiptUploadSection(l10n),
                  const SizedBox(height: 32),
                  _buildSecurityInfo(colors, l10n),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : () async {
                        if (_formKey.currentState!.validate()) {
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
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing...', style: TextStyle(fontWeight: FontWeight.bold)),
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

  String? _selectedOperatorId;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    // Pre-fill amount and track plan/operator details if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      
      if (extra is Map<String, dynamic>) {
        setState(() {
          _selectedOperatorId = extra['operatorId'] as String?;
          _selectedPlanId = extra['planId'] as String?;
          final price = extra['price'];
          if (price != null) {
            _amountController.text = NumberFormat.decimalPattern().format(price);
          }
        });
      } else if (extra is double) {
        _amountController.text = NumberFormat.decimalPattern().format(extra);
      }
    });
  }

  Future<void> _pickReceipt(AppLocalizations l10n) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _receiptPhoto = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photo: $e')),
        );
      }
    }
  }

  Future<void> _processSubscription(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final authUser = ref.read(supabaseProvider).auth.currentUser;
    if (authUser == null) return;

    setState(() => _isUploading = true);

    try {
      final client = ref.read(supabaseProvider);

      // Parse amount
      final amountStr = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountStr) ?? 8500.0;

      String? receiptUrl;

      // 1. Upload manual receipt photo if provided
      if (_receiptPhoto != null) {
        final ext = _receiptPhoto!.extension ?? 'png';
        final storagePath = 'receipts/${authUser.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        
        if (kIsWeb) {
          await client.storage.from('documents').uploadBinary(
            storagePath,
            _receiptPhoto!.bytes!,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );
        } else {
          await client.storage.from('documents').upload(
            storagePath,
            File(_receiptPhoto!.path!),
            fileOptions: const FileOptions(contentType: 'image/png'),
          );
        }
        receiptUrl = client.storage.from('documents').getPublicUrl(storagePath);
      }

      if (widget.policyId != null && widget.policyId!.isNotEmpty) {
        // SCENARIO A: Paying for an existing accepted policy
        final receiptNum = 'REC-${DateTime.now().millisecondsSinceEpoch}';
        await client
            .from('policies')
            .update({
              'status': 'paid',
              'paid_at': DateTime.now().toIso8601String(),
              'receipt_number': receiptNum,
              'receipt_url': receiptUrl,
            })
            .eq('id', widget.policyId!);
      } else {
        // SCENARIO B: Creating a new direct subscription
        // Use tracked IDs if available, otherwise fallback
        final planId = _selectedPlanId;
        final operatorId = _selectedOperatorId;

        if (planId == null || operatorId == null) {
           // Fallback to fetching a random one if somehow not provided (legacy)
           final planData = await client.from('plans').select('id, operator_id').limit(1).maybeSingle();
           if (planData == null) throw Exception('No plan selected');
           
           await client.from('policies').insert({
              'client_id': authUser.id,
              'plan_id': planData['id'],
              'operator_id': planData['operator_id'],
              'status': 'pending',
              'amount': amount,
              'submitted_at': DateTime.now().toIso8601String(),
              'receipt_url': receiptUrl,
              'plan_name': 'Comprehensive Auto Takaful',
            });
        } else {
            await client.from('policies').insert({
              'client_id': authUser.id,
              'plan_id': planId,
              'operator_id': operatorId,
              'status': 'pending',
              'amount': amount,
              'submitted_at': DateTime.now().toIso8601String(),
              'receipt_url': receiptUrl,
              'plan_name': 'Comprehensive Auto Takaful',
            });
        }
      }

      if (mounted) {
        _showSuccessDialog(context, l10n);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Payment Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    final now = DateTime.now();
    final receiptNumber = 'REC-${now.millisecondsSinceEpoch}';
    final dateStr = DateFormat('dd MMM yyyy – HH:mm').format(now);
    final methodName = _selectedCard == 'dahabiya' ? 'Edahabia' : 'CIB';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Success Icon ──────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accepted.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accepted,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.paymentReceiptTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 14, color: AppColors.accepted),
                  const SizedBox(width: 6),
                  Text(
                    l10n.paymentReceiptSentToOperator,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accepted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ── Receipt Card ─────────────────────────────────────────
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.slate100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.slate200),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow(
                        l10n.paymentReceiptNumber,
                        receiptNumber,
                        Icons.tag_rounded,
                        context,
                      ),
                      const Divider(height: 20),
                      _buildReceiptRow(
                        l10n.paymentDate,
                        dateStr,
                        Icons.calendar_today_rounded,
                        context,
                      ),
                      const Divider(height: 20),
                      _buildReceiptRow(
                        l10n.paymentMethod,
                        methodName,
                        Icons.credit_card_rounded,
                        context,
                      ),
                      const Divider(height: 20),
                      _buildReceiptRow(
                        l10n.amountToPay,
                        '${_amountController.text} ${l10n.dzd}',
                        Icons.account_balance_wallet_rounded,
                        context,
                        valueColor: AppColors.primaryGreen,
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Operator Confirmation Banner ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0097A7).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0097A7).withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF0097A7),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.paymentVerified,
                        style: const TextStyle(
                          color: Color(0xFF0097A7),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/client'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.backToDashboard,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _shareReceiptPhoto(l10n),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    l10n.downloadReceipt,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    IconData icon,
    BuildContext context, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.colors.slate500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? context.colors.darkText,
                  fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareReceiptPhoto(AppLocalizations l10n) async {
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: l10n.paymentReceiptTitle,
        );
      }
    } catch (e) {
      debugPrint('Error sharing receipt: $e');
    }
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

  Widget _buildReceiptUploadSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF0097A7), size: 20),
              const SizedBox(width: 8),
              Text(
                'Manual Payment Proof',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If you paid via bank transfer or CCP, please upload the receipt photo here.',
            style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (_receiptPhoto != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _receiptPhoto!.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () => setState(() => _receiptPhoto = null),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickReceipt(l10n),
              icon: const Icon(Icons.add_a_photo_rounded, size: 18),
              label: Text(_receiptPhoto == null ? 'Upload Receipt Photo' : 'Change Photo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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
