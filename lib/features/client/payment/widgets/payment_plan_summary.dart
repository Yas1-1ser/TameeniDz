import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/theme/app_colors.dart';

class PaymentPlanSummary extends StatelessWidget {
  const PaymentPlanSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
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
                child: _miniCard(context, AppColors.goldAccent, 'Edahabia'),
              ),
            ),
            Transform.translate(
              offset: const Offset(20, -10),
              child: Transform.rotate(
                angle: 0.1,
                child: _miniCard(context, Colors.blue.shade800, 'CIB'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(BuildContext context, Color color, String text) {
    return Container(
      width: 220,
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.39),
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
                style: TextStyle(
                  color: context.colors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '**** **** **** 8824',
            style: TextStyle(
              color: context.colors.surface,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
