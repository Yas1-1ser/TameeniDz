import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar')) {
    _loadLocale();
  }

  static const _key = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && mounted) {
      // FIX: set state after async load so the UI rebuilds
      state = Locale(code);
    }
  }

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
