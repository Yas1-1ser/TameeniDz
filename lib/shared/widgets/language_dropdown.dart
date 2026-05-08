import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/locale_provider.dart';

class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  static const _languages = [
    ('AR', 'ar'),
    ('TZM', 'kab'),
    ('FR', 'fr'),
    ('EN', 'en'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale.languageCode,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGreen, size: 16),
          alignment: AlignmentDirectional.centerEnd,
          isDense: true,
          dropdownColor: AppColors.surface,
          items: _languages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang.$2,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  lang.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(localeProvider.notifier).setLocale(Locale(val));
            }
          },
        ),
      ),
    );
  }
}
