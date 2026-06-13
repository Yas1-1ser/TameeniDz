import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_extension.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      primary: AppColors.primaryGreen,
      secondary: AppColors.goldAccent,
      surface: AppColors.beigeCard,
      onPrimary: Colors.white,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    ),
    scaffoldBackgroundColor: AppColors.beigeBg,
    fontFamily: 'Manrope',
    dividerColor: AppColors.warmDivider,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.beigeCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.warmDivider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 14),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.beigeCard,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.beigeDeep,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.slate500,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.beigeDeep,
      indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryGreen
              : AppColors.slate500,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.beigeDeep,
      selectedIconTheme: IconThemeData(color: AppColors.primaryGreen),
      selectedLabelTextStyle: TextStyle(color: AppColors.primaryGreen),
      unselectedIconTheme: IconThemeData(color: AppColors.slate500),
      unselectedLabelTextStyle: TextStyle(color: AppColors.slate500),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.beigeDeep),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.slate500,
      textColor: AppColors.onSurface,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.primaryGreen
            : AppColors.slate500;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.primaryGreen.withValues(alpha: 0.28)
            : AppColors.slate200;
      }),
    ),
    extensions: [AppColorsExtension.light()],
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
      primary: AppColors.primaryGreen,
      secondary: AppColors.goldAccent,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'Manrope',
    dividerColor: AppColors.dividerDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onSurfaceDark,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(56),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreenDark, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariantDark, fontSize: 14),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surfaceDark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      selectedItemColor: AppColors.primaryGreenDark,
      unselectedItemColor: AppColors.onSurfaceVariantDark,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      indicatorColor: AppColors.inversePrimary.withValues(alpha: 0.16),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.inversePrimary
              : AppColors.onSurfaceVariantDark,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      selectedIconTheme: IconThemeData(color: AppColors.primaryGreenDark),
      selectedLabelTextStyle: TextStyle(color: AppColors.primaryGreenDark),
      unselectedIconTheme: IconThemeData(color: AppColors.onSurfaceVariantDark),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.onSurfaceVariantDark,
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.surfaceContainerDark),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.onSurfaceVariantDark,
      textColor: AppColors.onSurfaceDark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.inversePrimary
            : AppColors.onSurfaceVariantDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.inversePrimary.withValues(alpha: 0.26)
            : AppColors.outlineDark;
      }),
    ),
    extensions: [AppColorsExtension.dark()],
  );
}
