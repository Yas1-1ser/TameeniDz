import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: progress.clamp(0.0, 1.0),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
