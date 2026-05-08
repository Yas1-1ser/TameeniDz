import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

extension BuildContextThemeX on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
