import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps any widget with a smooth fade + slide-up page entry animation.
/// Optimized with RepaintBoundary to ensure smooth performance.
class PageEntryAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const PageEntryAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates the static page content from repainting during the transition ticks
    return RepaintBoundary(
      child: child,
    )
        .animate()
        .fadeIn(duration: duration, delay: delay, curve: Curves.easeOut)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: duration,
          delay: delay,
          curve: Curves.easeOut,
        );
  }
}
