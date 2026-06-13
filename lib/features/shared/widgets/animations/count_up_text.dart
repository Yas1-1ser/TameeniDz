import 'package:flutter/material.dart';
import 'package:tameenidz/core/utils/number_utils.dart';

class CountUpText extends StatelessWidget {
  final double value;
  final TextStyle style;
  final String suffix;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.suffix = '',
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    final formatter = safeNumberFormat(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, val, child) {
        return Text(
          '${formatter.format(val.toInt())}$suffix',
          style: style,
        );
      },
    );
  }
}
