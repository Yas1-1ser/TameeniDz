import 'package:flutter/material.dart';

class StaggeredListItem extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: child,
        ),
      ),
    );
  }
}
