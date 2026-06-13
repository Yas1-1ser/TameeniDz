import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/responsive_layout.dart';

class AppTextStyles {
  static TextStyle heading(BuildContext context) => TextStyle(
    fontSize: ResponsiveLayout.isMobile(context) ? 22 : 26,
    fontWeight: FontWeight.bold,
    color: context.colors.onSurface,
  );

  static TextStyle subheading(BuildContext context) => TextStyle(
    fontSize: ResponsiveLayout.isMobile(context) ? 17 : 20,
    fontWeight: FontWeight.bold,
    color: context.colors.onSurface,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: context.colors.onSurface,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: context.colors.onSurfaceVariant,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: context.colors.onPrimary,
  );
}
