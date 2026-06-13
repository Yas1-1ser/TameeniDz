// lib/core/utils/responsive.dart

import 'package:flutter/material.dart';

/// Device breakpoints
enum DeviceType { mobile, tablet, desktop }

class Responsive {
  static late MediaQueryData _mq;
  static late double screenW;
  static late double screenH;
  static late double pixelRatio;
  static late DeviceType device;

  /// Call this once at the top of every build() method:
  /// Responsive.init(context);
  static void init(BuildContext context) {
    _mq       = MediaQuery.of(context);
    screenW   = _mq.size.width;
    screenH   = _mq.size.height;
    pixelRatio = _mq.devicePixelRatio;

    if (screenW >= 1100) {
      device = DeviceType.desktop;
    } else if (screenW >= 600) {
      device = DeviceType.tablet;
    } else {
      device = DeviceType.mobile;
    }
  }

  static bool get isMobile  => device == DeviceType.mobile;
  static bool get isTablet  => device == DeviceType.tablet;
  static bool get isDesktop => device == DeviceType.desktop;

  /// Fluid horizontal padding: 16 on mobile → 32 on tablet → 80 on desktop
  static double get hPad {
    if (isDesktop) return screenW * 0.08;
    if (isTablet)  return 32;
    return 16;
  }

  /// Max content width (center content on wide screens)
  static double get maxWidth {
    if (isDesktop) return 900;
    if (isTablet)  return 680;
    return double.infinity;
  }

  /// Responsive font scale (base = 375px wide phone)
  static double sp(double size) {
    final scale = (screenW / 375).clamp(0.85, 1.4);
    return size * scale;
  }

  /// Responsive size (width-relative)
  static double w(double size) => screenW * (size / 375);

  /// Responsive size (height-relative)
  static double h(double size) => screenH * (size / 812);

  /// Grid column count based on device and optional item min width
  static int columns({int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop) return desktop;
    if (isTablet)  return tablet;
    return mobile;
  }

  /// Adaptive value: pick the right value for current device
  static T adaptive<T>({required T mobile, required T tablet, T? desktop}) {
    if (isDesktop) return desktop ?? tablet;
    if (isTablet)  return tablet;
    return mobile;
  }
}
