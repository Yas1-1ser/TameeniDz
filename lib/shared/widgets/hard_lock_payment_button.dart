import 'package:flutter/material.dart';
import '../enums/policy_status.dart';
import '../../core/constants/app_colors.dart';

/// Decree 21-81 compliance: button is DISABLED until Final Acceptance.
class HardLockPaymentButton extends StatelessWidget {
  final PolicyStatus status;
  final VoidCallback onPay;

  const HardLockPaymentButton({
    super.key,
    required this.status,
    required this.onPay,
  });

  bool get _isUnlocked => status == PolicyStatus.accepted;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isUnlocked ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 400),
      child: ElevatedButton.icon(
        onPressed: _isUnlocked ? onPay : null,
        icon: Icon(_isUnlocked ? Icons.lock_open : Icons.lock, size: 18),
        label: Text(
          _isUnlocked ? 'ادفع الآن' : 'في انتظار القبول النهائي',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isUnlocked ? AppColors.goldAccent : Colors.grey,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
