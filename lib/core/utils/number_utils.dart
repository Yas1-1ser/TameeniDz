// lib/core/utils/number_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Safely creates a NumberFormat by trying the full locale string, 
/// the language code, the default locale, and finally a guaranteed 
/// fallback (e.g., 'fr' or standard pattern), preventing any crashes 
/// on unsupported locales like 'kab'.
NumberFormat safeNumberFormat(BuildContext context, {String? pattern}) {
  final localeStr = Localizations.localeOf(context).toString();
  final langCode = Localizations.localeOf(context).languageCode;

  // 1. Try with full locale string (e.g., kab_DZ, ar_DZ)
  try {
    return pattern != null
        ? NumberFormat(pattern, localeStr)
        : NumberFormat.decimalPattern(localeStr);
  } catch (_) {}

  // 2. Try with language code only (e.g., kab, ar)
  try {
    return pattern != null
        ? NumberFormat(pattern, langCode)
        : NumberFormat.decimalPattern(langCode);
  } catch (_) {}

  // 3. Try with pattern only (uses default platform locale or standard)
  try {
    return pattern != null
        ? NumberFormat(pattern)
        : NumberFormat.decimalPattern();
  } catch (_) {}

  // 4. Guaranteed fallback (French formatting works everywhere and uses standard spaces)
  return pattern != null
      ? NumberFormat(pattern, 'fr')
      : NumberFormat.decimalPattern('fr');
}
