import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

/// Wraps any screen body with a rich beige background + subtle decorative elements.
/// Optimized with RepaintBoundary to ensure background decorations don't impact scroll performance.
class BeigeBgDecoration extends StatelessWidget {
  const BeigeBgDecoration({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // PERFORMANCE: Isolate the decorative background so it doesn't repaint when the child (list) scrolls.
        const RepaintBoundary(
          child: _BackgroundElements(),
        ),
        // Actual screen content
        child,
      ],
    );
  }
}

class _BackgroundElements extends StatelessWidget {
  const _BackgroundElements();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = colors.beigeBg;
    final circleColor = colors.primaryGreen.withValues(alpha: isDark ? 0.04 : 0.035);
    final circleBorderColor = colors.primaryGreen.withValues(alpha: isDark ? 0.04 : 0.07);
    final goldColor = colors.goldAccent.withValues(alpha: isDark ? 0.06 : 0.10);
    final ornamentGold = colors.goldAccent.withValues(alpha: isDark ? 0.11 : 0.18);

    return Container(
      width: size.width,
      height: size.height,
      color: bgColor,
      child: Stack(
        children: [
          // Top-right large decorative circle
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleBorderColor, width: 1),
                color: circleColor,
              ),
            ),
          ),

          // Top-right inner circle
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.45,
              height: size.width * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: goldColor, width: 1),
              ),
            ),
          ),

          // Bottom-left large decorative circle
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.70,
              height: size.width * 0.70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleBorderColor, width: 1),
                color: circleColor,
              ),
            ),
          ),

          // Islamic geometric corner ornament
          Positioned(
            top: 60,
            left: 20,
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _CornerOrnamentPainter(color: ornamentGold),
            ),
          ),
          
          // Scattered small gold dots
          ..._buildGoldDots(context, size, isDark),
        ],
      ),
    );
  }

  List<Widget> _buildGoldDots(BuildContext context, Size size, bool isDark) {
    final colors = context.colors;
    final positions = [
      [0.08, 0.22, 3.5, isDark ? 0.15 : 0.25],
      [0.85, 0.18, 2.5, isDark ? 0.12 : 0.20],
      [0.15, 0.72, 4.0, isDark ? 0.10 : 0.18],
      [0.90, 0.55, 3.0, isDark ? 0.13 : 0.22],
    ];

    return positions.map((p) {
      return Positioned(
        left: size.width * p[0],
        top: size.height * p[1],
        child: Container(
          width: p[2],
          height: p[2],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.goldAccent.withValues(alpha: p[3]),
          ),
        ),
      );
    }).toList();
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  _CornerOrnamentPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final s = size.width;
    canvas.drawLine(Offset(0, s * 0.5), Offset(s * 0.38, s * 0.5), paint);
    canvas.drawLine(Offset(s * 0.5, 0), Offset(s * 0.5, s * 0.38), paint);
    canvas.drawCircle(Offset(s * 0.5, s * 0.5), 2.5, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_CornerOrnamentPainter old) => old.color != color;
}
