import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:flutter/material.dart';

import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      appBar: AppBar(
        title: Text(
          'العروض المتاحة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: context.colors.surface,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageEntryAnimation(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.loyalty_outlined, size: 80, color: AppColors.gold),
            SizedBox(height: 20),
            Text(
              'العروض والخطط التأمينية قادمة قريبًا',
              style: TextStyle(
                fontSize: 18,
                color: context.colors.darkText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )),
    );
  }
}
