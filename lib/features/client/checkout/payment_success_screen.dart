import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';

import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/router/app_routes.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      body: PageEntryAnimation(child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.accepted, size: 100),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.paymentSuccessful,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.paymentSuccessMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.slate500),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: SpringButton(child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: context.colors.beigeBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppLocalizations.of(context)!.backToDashboard),
                )),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
