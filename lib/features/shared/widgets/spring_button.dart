import 'package:flutter/material.dart';

/// A premium, tactile spring-physics wrapper that scales elements to 0.97 on press.
/// Optimized with ValueNotifier to prevent full widget rebuilds during the press animation.
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SpringButton({super.key, required this.child, this.onTap});

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton> {
  // PERFORMANCE: Use ValueNotifier to isolate rebuilds to only the scale transformation
  final ValueNotifier<double> _scale = ValueNotifier(1.0);

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _scale.value = 0.97,
      onPointerUp: (_) => _scale.value = 1.0,
      onPointerCancel: (_) => _scale.value = 1.0,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ValueListenableBuilder<double>(
          valueListenable: _scale,
          builder: (context, scale, child) {
            return AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutBack,
              child: child!,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
