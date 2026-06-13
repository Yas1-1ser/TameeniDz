import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrincipleTile extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final int delayMs;

  const PrincipleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.beigeCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.slate100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.slate500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
        .animate(delay: delayMs.ms)
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }
}
