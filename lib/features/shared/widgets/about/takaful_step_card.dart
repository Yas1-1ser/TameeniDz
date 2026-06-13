import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TakafulStepCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final IconData icon;
  final int delayMs;

  const TakafulStepCard({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.icon,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.beigeCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.goldAccent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(color: context.colors.beigeCard, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: context.colors.slate500, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: delayMs.ms).fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0);
  }
}
