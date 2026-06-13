import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'widgets/payment_form.dart';
import 'widgets/payment_plan_summary.dart';
import 'widgets/payment_receipt_view.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String? policyId;
  const PaymentScreen({super.key, this.policyId});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _screenshotController = ScreenshotController();
  
  String? _selectedOperatorId;
  String? _selectedPlanId;
  double? _prefilledPrice;

  // Success view state
  bool _isSuccess = false;
  String _receiptNumber = '';
  String _dateStr = '';
  String _methodName = '';
  String _amountText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        setState(() {
          _selectedOperatorId = extra['operatorId'] as String?;
          _selectedPlanId = extra['planId'] as String?;
          final price = extra['price'];
          if (price is double) {
            _prefilledPrice = price;
          }
        });
      } else if (extra is double) {
        setState(() {
          _prefilledPrice = extra;
        });
      }
    });
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
      body: PageEntryAnimation(child: _isSuccess
          ? PaymentReceiptView(
              screenshotController: _screenshotController,
              receiptNumber: _receiptNumber,
              dateStr: _dateStr,
              methodName: _methodName,
              amountText: _amountText,
              l10n: l10n,
              onBackToDashboard: () => context.go('/client'),
              onShareReceipt: () => _shareReceiptPhoto(l10n),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.electronicPayment, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                  const SizedBox(height: 8),
                  Text(l10n.choosePaymentMethod, style: TextStyle(fontSize: 14, color: colors.slate500)),
                  const SizedBox(height: 32),
                  const PaymentPlanSummary(),
                  const SizedBox(height: 32),
                  PaymentForm(
                    policyId: widget.policyId,
                    selectedPlanId: _selectedPlanId,
                    selectedOperatorId: _selectedOperatorId,
                    prefilledPrice: _prefilledPrice,
                    onSuccess: ({
                      required String receiptNumber,
                      required String dateStr,
                      required String methodName,
                      required String amountText,
                    }) {
                      setState(() {
                        _receiptNumber = receiptNumber;
                        _dateStr = dateStr;
                        _methodName = methodName;
                        _amountText = amountText;
                        _isSuccess = true;
                      });
                    },
                  ),
                ],
              ),
            )),
    );
  }

  Future<void> _shareReceiptPhoto(AppLocalizations l10n) async {
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);
        await SharePlus.instance.share(
          ShareParams(
            text: l10n.paymentReceiptTitle,
            files: [XFile(imagePath)],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing receipt: $e');
    }
  }
}
