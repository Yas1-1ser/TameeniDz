import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/providers/locale_provider.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

const _languages = [
  ('العربية', 'ar', 'ع', '🇩🇿'),
  ('Taqbaylit', 'kab', 'ⵣ', 'ⵣ'),
  ('Français', 'fr', 'F', '🇫🇷'),
  ('English', 'en', 'E', '🇬🇧'),
];

class LanguagePickerButton extends ConsumerWidget {
  final Color? textColor;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;

  const LanguagePickerButton({
    super.key,
    this.textColor,
    this.iconColor = AppColors.goldAccent,
    this.borderColor = AppColors.goldAccent,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;
    
    // Find current language data
    final currentLang = _languages.firstWhere(
      (lang) => lang.$2 == langCode || (langCode == 'tzm' && lang.$2 == 'kab'),
      orElse: () => _languages[0],
    );

    final fontName = (langCode == 'ar' || langCode == 'kab' || langCode == 'tzm') ? 'Cairo' : 'Poppins';

    return GestureDetector(
      onTap: () => _showLanguageBottomSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor == Colors.transparent 
              ? Colors.white.withValues(alpha: 0.15) 
              : backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor == AppColors.goldAccent 
                ? AppColors.goldAccent.withValues(alpha: 0.6) 
                : borderColor, 
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldAccent.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(
              currentLang.$4, // Current Language Flag Emoji
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(width: 8),
            Text(
              currentLang.$1, // Current Language Native Name
              style: TextStyle(
                fontFamily: fontName,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor ?? context.colors.darkText,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: iconColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isScrollControlled: true,
      elevation: 0,
      builder: (ctx) {
        return Consumer(
          builder: (ctx2, ref2, _) {
            return const _LanguageSheetContent();
          },
        );
      },
    );
  }
}

class _LanguageSheetContent extends ConsumerWidget {
  const _LanguageSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: context.colors.beigeBg.withValues(alpha: 0.90), // Premium beige base with opacity
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sheet Handle Indicator
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.translate_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.selectLanguage.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                        fontFamily: 'Cairo',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 2.5,
                  color: AppColors.goldAccent,
                ),
                const SizedBox(height: 28),

                // Language Rows
                ..._languages.map((lang) {
                  final isSelected = currentLocale.languageCode == lang.$2 || 
                                     (currentLocale.languageCode == 'tzm' && lang.$2 == 'kab');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _LanguageItemRow(
                      name: lang.$1,
                      badge: lang.$4, // Flag
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(Locale(lang.$2));
                        Navigator.of(context).pop(); // immediate close, no delay
                        Feedback.forTap(context);
                      },
                    ),
                  );
                }),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageItemRow extends StatefulWidget {
  const _LanguageItemRow({
    required this.name,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_LanguageItemRow> createState() => _LanguageItemRowState();
}

class _LanguageItemRowState extends State<_LanguageItemRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.goldAccent.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.goldAccent
                  : AppColors.goldAccent.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.goldAccent.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Circular flag badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.goldAccent.withValues(alpha: 0.15)
                      : AppColors.goldAccent.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.badge,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Native script name
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected ? context.colors.darkText : context.colors.slate500,
                  fontFamily: (widget.name == 'العربية' || widget.name == 'Taqbaylit') ? 'Cairo' : 'Poppins',
                ),
              ),
              const Spacer(),

              // Gold checkmark selector
              if (widget.isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.goldAccent,
                  size: 22,
                ).animate().scale(curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: langCode == 'tzm' ? 'kab' : langCode,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.goldAccent),
        elevation: 8,
        style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.darkText),
        onChanged: (String? newValue) {
          if (newValue != null) {
            ref.read(localeProvider.notifier).setLocale(Locale(newValue));
          }
        },
        items: const [
          DropdownMenuItem(
            value: 'ar',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇩🇿  '),
                Text('العربية'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'kab',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ⵣ  '),
                Text('Taqbaylit'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'fr',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇫🇷  '),
                Text('Français'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇬🇧  '),
                Text('English'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
