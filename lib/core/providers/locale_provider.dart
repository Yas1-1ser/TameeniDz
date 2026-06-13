import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FIXED: provider now accepts initial locale loaded synchronously in main()
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  // FIXED: accepts initialLocale pre-loaded from SharedPreferences before runApp
  // — eliminates the 1-2 frame Arabic flash on devices with a saved preference.
  LocaleNotifier({String initialLocale = 'ar'}) : super(Locale(initialLocale));

  static const _key = 'app_locale';

  /// Call this when the user picks a language from the switcher.
  /// The state change triggers a rebuild of TaminyEliteApp via ref.watch,
  /// which updates MaterialApp.router's `locale:` parameter and reloads
  /// all AppLocalizations delegates — so FR/TR/EN strings appear instantly.
  Future<void> setLocale(Locale locale) async {
    state = locale; // sync update first → immediate UI rebuild
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode); // persist
  }
}
