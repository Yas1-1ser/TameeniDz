import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LegalCard extends StatelessWidget {
  final String title;
  final String body;
  final String icon;
  final int delayMs;
  final List<String>? bulletPoints;

  const LegalCard({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    this.delayMs = 0,
    this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.beigeCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                body,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.darkText,
                  height: 1.6,
                ),
              ),
              if (bulletPoints != null) ...[
                SizedBox(height: 12),
                ...bulletPoints!.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.goldAccent,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.slate500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
        .animate(delay: delayMs.ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
