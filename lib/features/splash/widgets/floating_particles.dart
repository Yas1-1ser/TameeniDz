// lib/widgets/splash/floating_particles.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;

  const FloatingParticles({
    super.key,
    this.count = 8,
    this.color = const Color(0xFFFFD700),
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<double> _leftPositions;
  late List<double> _sizes;
  late List<double> _opacities;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.count, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 3000 + _random.nextInt(3000)),
      )..repeat();
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.1, end: -0.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear),
      );
    }).toList();

    _leftPositions = List.generate(widget.count, (_) => 0.1 + _random.nextDouble() * 0.8);
    _sizes = List.generate(widget.count, (_) => 2.0 + _random.nextDouble() * 3.0);
    _opacities = List.generate(widget.count, (_) => 0.2 + _random.nextDouble() * 0.3);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.count, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: MediaQuery.of(context).size.width * _leftPositions[index],
              top: MediaQuery.of(context).size.height * _animations[index].value,
              child: Container(
                width: _sizes[index],
                height: _sizes[index],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: _opacities[index]),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
