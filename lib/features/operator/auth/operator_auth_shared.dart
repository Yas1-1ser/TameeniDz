import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class BeigeBackground extends StatelessWidget {
  const BeigeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDFBF7), // Cream
            Color(0xFFF4EBE1), // Soft Beige
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle patterns or glows can be added here
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC5A059).withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration buildInputDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
  required Color accent,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.midBrown, fontFamily: 'Cairo', fontSize: 14),
    prefixIcon: Icon(icon, color: accent, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: context.colors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color(0xFFEEDCC6).withValues(alpha: 0.5), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
  );
}

class SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;

  const SectionLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accent,
              fontFamily: 'Cairo',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontFamily: 'Cairo', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientCta extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final Color accent;
  final Color dark;
  final VoidCallback onTap;

  const GradientCta({
    super.key,
    required this.label,
    required this.icon,
    required this.loading,
    required this.accent,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [accent, dark],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: context.colors.surface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(icon, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class SuccessView extends StatelessWidget {
  final dynamic company;
  final bool isAr;

  const SuccessView({super.key, required this.company, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final companyColor = company is CompanyOption ? (company as CompanyOption).color : AppColors.primaryGreen;
    final companyId = company is CompanyOption ? (company as CompanyOption).id : '';

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: companyColor, size: 64)
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.accountCreatedSuccess,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: context.colors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.checkEmailConfirm,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.midBrown,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (companyId == 'al_ittihad') {
                    context.go('/ai/login');
                  } else {
                    context.go('/at/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: companyColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.goToLogin,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyOption {
  final String id;
  final String nameAr;
  final String nameFr;
  final Color color;
  final Color darkColor;

  const CompanyOption({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.color,
    required this.darkColor,
  });
}

const operatorCompanies = [
  CompanyOption(
    id: 'algeria_takaful',
    nameAr: 'جزائر تكافل',
    nameFr: 'Algérie Takaful',
    color: AppColors.primaryGreen,
    darkColor: AppColors.primaryDark,
  ),
  CompanyOption(
    id: 'al_ittihad',
    nameAr: 'الجزائر المتحدة',
    nameFr: 'L\'Union Algérienne',
    color: AppColors.alIttihadGreen,
    darkColor: Color(0xFF073D27),
  ),
];
