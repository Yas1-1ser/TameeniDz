import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../../core/providers/supabase_provider.dart';

import 'package:tameenidz/features/shared/data/policy_repository.dart';

class PaymentForm extends ConsumerStatefulWidget {
  final String? policyId;
  final String? selectedPlanId;
  final String? selectedOperatorId;
  final double? prefilledPrice;
  final void Function({
    required String receiptNumber,
    required String dateStr,
    required String methodName,
    required String amountText,
  }) onSuccess;

  const PaymentForm({
    super.key,
    this.policyId,
    this.selectedPlanId,
    this.selectedOperatorId,
    this.prefilledPrice,
    required this.onSuccess,
  });

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCard = 'dahabiya';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  PlatformFile? _receiptPhoto;
  bool _isUploading = false;
  bool _isFixedAmount = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledPrice != null && widget.prefilledPrice! > 0) {
      _amountController.text = NumberFormat.decimalPattern().format(widget.prefilledPrice);
      _isFixedAmount = true;
    } else {
      _amountController.text = '0';
    }
  }

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

    return Form(
      key: _formKey,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardSelection(colors, l10n),
              const SizedBox(height: 32),
              _buildAmountInput(colors, l10n),
              const SizedBox(height: 32),
              _buildCardInputs(colors, l10n),
              const SizedBox(height: 24),
              _buildReceiptUploadSection(l10n),
              const SizedBox(height: 32),
              _buildSecurityInfo(colors, l10n),
              const SizedBox(height: 32),
              _buildPayButton(l10n),
              const SizedBox(height: 40),
            ],
          ),
          if (_isUploading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCardSelection(AppColorsExtension colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _selectionItem(l10n.edahabiaCard, 'dahabiya', Icons.credit_card_rounded, AppColors.goldAccent)),
        SizedBox(width: 16),
        Expanded(child: _selectionItem('CIB', 'cib', Icons.payment_rounded, Colors.blue.shade800)),
      ],
    );
  }

  Widget _selectionItem(String label, String value, IconData icon, Color color) {
    final isSelected = _selectedCard == value;
    final colors = context.colors;
    return GestureDetector(
      onTap: () => setState(() => _selectedCard = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : colors.slate200, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : colors.slate500, size: 32),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : colors.slate500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(AppColorsExtension colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.amountToPay, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.darkText)),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          readOnly: _isFixedAmount,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          decoration: InputDecoration(
            suffixText: l10n.dzd,
            filled: true,
            fillColor: _isFixedAmount ? colors.slate100.withValues(alpha: 0.5) : colors.slate100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            helperText: _isFixedAmount ? 'This amount is pre-calculated based on your request.' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCardInputs(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel(colors, l10n.cardHolder),
          const SizedBox(height: 8),
          _buildTextField(
            l10n.cardHolder,
            _cardHolderController,
            'Full Name',
            Icons.person_outline,
            validator: (v) => (v == null || v.isEmpty) ? l10n.enterCardHolder : null,
          ),
          const SizedBox(height: 16),
          _buildInputLabel(colors, l10n.cardNumber),
          const SizedBox(height: 8),
          _buildTextField(
            l10n.cardNumber,
            _cardNumberController,
            '**** **** **** ****',
            Icons.credit_card,
            formatters: [
              _CardNumberInputFormatter(),
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
                    _buildInputLabel(colors, l10n.expiryDate),
                    const SizedBox(height: 8),
                    _buildTextField(
                      l10n.expiryDate,
                      _expiryController,
                      'MM/YY',
                      Icons.calendar_today_outlined,
                      formatters: [
                        _ExpiryDateInputFormatter(),
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
                    _buildInputLabel(colors, l10n.cvv),
                    const SizedBox(height: 8),
                    _buildTextField(
                      l10n.cvv,
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

  Widget _buildInputLabel(AppColorsExtension colors, String label) {
    return Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.darkText));
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final colors = context.colors;
    return TextFormField(
      controller: ctrl,
      inputFormatters: formatters,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: colors.slate400),
        filled: true,
        fillColor: colors.slate100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.slate200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.slate200)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildReceiptUploadSection(AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF0097A7), size: 20),
              const SizedBox(width: 8),
              Text(l10n.manualPaymentProof, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.uploadReceiptInstruction, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            l10n.maxImageSize5mb,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          if (_receiptPhoto != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_receiptPhoto!.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: () => setState(() => _receiptPhoto = null)),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickReceipt(l10n),
              icon: const Icon(Icons.add_a_photo_rounded, size: 18),
              label: Text(_receiptPhoto == null ? l10n.uploadReceiptPhoto : l10n.changePhoto),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.slate100, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.securePaymentNotice, style: TextStyle(color: colors.slate500, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildPayButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : () async {
          if (_formKey.currentState!.validate()) {
            await _processSubscription(l10n);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(l10n.payNow, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.processingPayment, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickReceipt(AppLocalizations l10n) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.imageSizeExceeds5mb)));
          }
          return;
        }
        setState(() => _receiptPhoto = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking photo: $e')));
      }
    }
  }

  Future<void> _processSubscription(AppLocalizations l10n) async {
    final authUser = ref.read(supabaseProvider).auth.currentUser;
    if (authUser == null) return;
    setState(() => _isUploading = true);

    try {
      final client = ref.read(supabaseProvider);
      final amountStr = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountStr) ?? 0.0;
      String? receiptUrl;

      if (_receiptPhoto != null) {
        final ext = _receiptPhoto!.extension ?? 'png';
        final storagePath = 'receipts/${authUser.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        
        if (kIsWeb) {
          await client.storage.from('documents').uploadBinary(storagePath, _receiptPhoto!.bytes!, fileOptions: const FileOptions(contentType: 'image/png'));
        } else {
          await client.storage.from('documents').upload(storagePath, File(_receiptPhoto!.path!), fileOptions: const FileOptions(contentType: 'image/png'));
        }
        receiptUrl = client.storage.from('documents').getPublicUrl(storagePath);
      }

      final now = DateTime.now();
      final receiptNum = 'REC-${now.millisecondsSinceEpoch}';
      final dateStr = DateFormat('dd MMM yyyy – HH:mm').format(now);
      final methodName = _selectedCard == 'dahabiya' ? 'Edahabia' : 'CIB';

      if (widget.policyId != null && widget.policyId!.isNotEmpty) {
        await ref.read(policyRepositoryProvider).markPaid(
          widget.policyId!,
          receiptUrl ?? '',
          receiptNumber: receiptNum,
        );
      } else {
        final planId = widget.selectedPlanId;
        final operatorId = widget.selectedOperatorId;

        if (planId == null || operatorId == null) {
          final planData = await client.from('plans').select('id, operator_id').limit(1).maybeSingle();
          if (planData == null) throw Exception('No plan selected');
          
          await client.from('policies').insert({
            'client_id': authUser.id,
            'plan_id': planData['id'],
            'operator_id': planData['operator_id'],
            'status': 'pending',
            'amount': amount,
            'submitted_at': now.toIso8601String(),
            'receipt_url': receiptUrl,
            'plan_name': 'Insurance Takaful Request',
          });
        } else {
          await client.from('policies').insert({
            'client_id': authUser.id,
            'plan_id': planId,
            'operator_id': operatorId,
            'status': 'pending',
            'amount': amount,
            'submitted_at': now.toIso8601String(),
            'receipt_url': receiptUrl,
            'plan_name': 'Insurance Takaful Request',
          });
        }
      }

      widget.onSuccess(
        receiptNumber: receiptNum,
        dateStr: dateStr,
        methodName: methodName,
        amountText: '${_amountController.text} ${l10n.dzd}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Payment Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}
