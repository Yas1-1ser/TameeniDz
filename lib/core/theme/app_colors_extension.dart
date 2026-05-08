import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension AppThemeColors on BuildContext {
  AppColorsExtension get colors {
    return Theme.of(this).extension<AppColorsExtension>()!;
  }
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryGreen;
  final Color primaryLight;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color goldAccent;
  final Color goldContainer;
  final Color onGoldContainer;
  final Color onSecondaryContainer;
  final Color background;
  final Color offWhite;
  final Color softSlate;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerLowest;
  final Color outlineVariant;
  final Color darkText;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color slate200;
  final Color slate400;
  final Color slate500;
  final Color slate700;
  final Color pending;
  final Color accepted;
  final Color rejected;
  final Color modRequested;
  final Color error;
  final Color subscriberFund;
  final Color shareholderFund;
  final Color alert30d;
  final Color alert7d;
  final Color alert24h;
  final Color sidebarBg;
  final Color alIttihadGreen;
  final Color primaryDark;
  final Color primaryTint;
  final Color primaryTintLight;
  final Color primaryOverlay;
  final Color inversePrimary;
  final Color onPrimaryContainerSoft;
  final Color surfaceContainerLow;
  final Color warmBackground;
  final Color bootButtonBg;
  final Color inputBorderLight;
  final Color slate100;
  final Color slate300;
  final Color outlineDark;

  Color get primary => primaryGreen;

  const AppColorsExtension({
    required this.primaryGreen,
    required this.primaryLight,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.goldAccent,
    required this.goldContainer,
    required this.onGoldContainer,
    required this.onSecondaryContainer,
    required this.background,
    required this.offWhite,
    required this.softSlate,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerLowest,
    required this.outlineVariant,
    required this.darkText,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.slate200,
    required this.slate400,
    required this.slate500,
    required this.slate700,
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.modRequested,
    required this.error,
    required this.subscriberFund,
    required this.shareholderFund,
    required this.alert30d,
    required this.alert7d,
    required this.alert24h,
    required this.sidebarBg,
    required this.alIttihadGreen,
    required this.primaryDark,
    required this.primaryTint,
    required this.primaryTintLight,
    required this.primaryOverlay,
    required this.inversePrimary,
    required this.onPrimaryContainerSoft,
    required this.surfaceContainerLow,
    required this.warmBackground,
    required this.bootButtonBg,
    required this.inputBorderLight,
    required this.slate100,
    required this.slate300,
    required this.outlineDark,
  });

  factory AppColorsExtension.light() {
    return const AppColorsExtension(
      primaryGreen: AppColors.primaryGreen,
      primaryLight: AppColors.primaryLight,
      primaryContainer: AppColors.primaryContainer,
      onPrimary: AppColors.onPrimary,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      goldAccent: AppColors.goldAccent,
      goldContainer: AppColors.goldContainer,
      onGoldContainer: Color(0xFF2E2405),
      onSecondaryContainer: AppColors.onSecondaryContainer,
      background: AppColors.background,
      offWhite: AppColors.offWhite,
      softSlate: AppColors.softSlate,
      surface: AppColors.surface,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      outlineVariant: AppColors.outlineVariant,
      darkText: AppColors.darkText,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      slate200: AppColors.slate200,
      slate400: AppColors.slate400,
      slate500: AppColors.slate500,
      slate700: AppColors.slate700,
      pending: AppColors.pending,
      accepted: AppColors.accepted,
      rejected: AppColors.rejected,
      modRequested: AppColors.modRequested,
      error: AppColors.error,
      subscriberFund: AppColors.subscriberFund,
      shareholderFund: AppColors.shareholderFund,
      alert30d: AppColors.alert30d,
      alert7d: AppColors.alert7d,
      alert24h: AppColors.alert24h,
      sidebarBg: AppColors.sidebarBg,
      alIttihadGreen: AppColors.alIttihadGreen,
      primaryDark: AppColors.primaryDark,
      primaryTint: AppColors.primaryTint,
      primaryTintLight: AppColors.primaryTintLight,
      primaryOverlay: AppColors.primaryOverlay,
      inversePrimary: AppColors.inversePrimary,
      onPrimaryContainerSoft: AppColors.onPrimaryContainerSoft,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      warmBackground: AppColors.warmBackground,
      bootButtonBg: AppColors.bootButtonBg,
      inputBorderLight: AppColors.inputBorderLight,
      slate100: AppColors.slate100,
      slate300: AppColors.slate300,
      outlineDark: AppColors.outlineDark,
    );
  }

  factory AppColorsExtension.dark() {
    return const AppColorsExtension(
      primaryGreen: AppColors.primaryGreen,
      primaryLight: AppColors.inversePrimary,
      primaryContainer: Color(0xFF244C36),
      onPrimary: AppColors.onPrimary,
      onPrimaryContainer: Color(0xFFAEE8C2),
      goldAccent: AppColors.goldAccent,
      goldContainer: Color(0xFF4A3D18),
      onGoldContainer: Color(0xFFFFE7A6),
      onSecondaryContainer: Color(0xFFFFE7A6),
      background: AppColors.backgroundDark,
      offWhite: AppColors.backgroundDark, // map soft bg to dark bg
      softSlate: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerDark,
      surfaceContainerLowest: AppColors.surfaceDark,
      outlineVariant: AppColors.outlineDark,
      darkText: AppColors.onSurfaceDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      slate200: AppColors.outlineDark,
      slate400: AppColors.onSurfaceVariantDark,
      slate500: AppColors.onSurfaceVariantDark,
      slate700: AppColors.onSurfaceDark,
      pending: AppColors.pending,
      accepted: AppColors.accepted,
      rejected: AppColors.rejected,
      modRequested: AppColors.modRequested,
      error: AppColors.error,
      subscriberFund: AppColors.subscriberFund,
      shareholderFund: AppColors.shareholderFund,
      alert30d: AppColors.alert30d,
      alert7d: AppColors.alert7d,
      alert24h: AppColors.alert24h,
      sidebarBg: AppColors.backgroundDark,
      alIttihadGreen: AppColors.alIttihadGreen,
      primaryDark: AppColors.inversePrimary,
      primaryTint: Color(0x261B6B45),
      primaryTintLight: Color(0x1A1B6B45),
      primaryOverlay: Color(0x331B6B45),
      inversePrimary: AppColors.inversePrimary,
      onPrimaryContainerSoft: AppColors.onPrimaryContainerSoft,
      surfaceContainerLow: AppColors.surfaceContainerDark,
      warmBackground: AppColors.backgroundDark,
      bootButtonBg: AppColors.surfaceContainerDark,
      inputBorderLight: AppColors.outlineDark,
      slate100: AppColors.surfaceContainerDark,
      slate300: AppColors.outlineDark,
      outlineDark: AppColors.outlineDark,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> copyWith() {
    return this;
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      goldContainer:
          Color.lerp(goldContainer, other.goldContainer, t)!,
      onGoldContainer:
          Color.lerp(onGoldContainer, other.onGoldContainer, t)!,
      onSecondaryContainer:
          Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      background: Color.lerp(background, other.background, t)!,
      offWhite: Color.lerp(offWhite, other.offWhite, t)!,
      softSlate: Color.lerp(softSlate, other.softSlate, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      darkText: Color.lerp(darkText, other.darkText, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      slate200: Color.lerp(slate200, other.slate200, t)!,
      slate400: Color.lerp(slate400, other.slate400, t)!,
      slate500: Color.lerp(slate500, other.slate500, t)!,
      slate700: Color.lerp(slate700, other.slate700, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      accepted: Color.lerp(accepted, other.accepted, t)!,
      rejected: Color.lerp(rejected, other.rejected, t)!,
      modRequested: Color.lerp(modRequested, other.modRequested, t)!,
      error: Color.lerp(error, other.error, t)!,
      subscriberFund: Color.lerp(subscriberFund, other.subscriberFund, t)!,
      shareholderFund: Color.lerp(shareholderFund, other.shareholderFund, t)!,
      alert30d: Color.lerp(alert30d, other.alert30d, t)!,
      alert7d: Color.lerp(alert7d, other.alert7d, t)!,
      alert24h: Color.lerp(alert24h, other.alert24h, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      alIttihadGreen: Color.lerp(alIttihadGreen, other.alIttihadGreen, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      primaryTintLight:
          Color.lerp(primaryTintLight, other.primaryTintLight, t)!,
      primaryOverlay: Color.lerp(primaryOverlay, other.primaryOverlay, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      onPrimaryContainerSoft:
          Color.lerp(onPrimaryContainerSoft, other.onPrimaryContainerSoft, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      warmBackground: Color.lerp(warmBackground, other.warmBackground, t)!,
      bootButtonBg: Color.lerp(bootButtonBg, other.bootButtonBg, t)!,
      inputBorderLight:
          Color.lerp(inputBorderLight, other.inputBorderLight, t)!,
      slate100: Color.lerp(slate100, other.slate100, t)!,
      slate300: Color.lerp(slate300, other.slate300, t)!,
      outlineDark: Color.lerp(outlineDark, other.outlineDark, t)!,
    );
  }
}
