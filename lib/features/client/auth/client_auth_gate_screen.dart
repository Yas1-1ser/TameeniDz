import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../../features/shared/widgets/responsive_layout.dart';
import 'package:tameenidz/features/shared/widgets/language_picker_button.dart';

/// Shown after the user picks "Client" on the role picker.
/// Lets them choose between logging in (existing account) or registering.
class ClientAuthGateScreen extends StatelessWidget {
  const ClientAuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: context.colors.darkText,
            size: 22,
          ),
          onPressed: () => context.go('/role'),
        ),
        actions: const [
          LanguagePickerButton(),
          SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PageEntryAnimation(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ResponsiveWidthConstraint(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Top Logo Centerpiece (90x90)
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.surface,
                          border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.7), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset('assets/images/logotameen.jpg', fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.clientPortalTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        l10n.client.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.slate500,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Buttons Section
                      Column(
                        children: [
                          // Login Button (Gradient CTA Pill)
                          GestureDetector(
                            onTap: () => context.go('/client/login'),
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
                              child: Text(
                                l10n.login,
                                style:  TextStyle(
                                  color: context.colors.surface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Register Button (Outline Pill)
                          GestureDetector(
                            onTap: () => context.go('/register/step1'),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: AppColors.primaryGreen,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                l10n.register,
                                style: const TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Decree Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.goldAccent.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 16,
                              color: AppColors.goldAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.decree2181Compliance,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.goldAccent,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
