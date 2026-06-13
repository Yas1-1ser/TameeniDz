// PATH: lib/features/operator/offers/widgets/operator_offer_card.dart
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../../shared/domain/models/plan_model.dart';

class OperatorOfferCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(bool)? onToggleBestValue;

  const OperatorOfferCard({
    super.key,
    required this.plan,
    this.onEdit,
    this.onDelete,
    this.onToggleBestValue,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'verified':
        return Icons.verified_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'car':
      case 'rafik':
        return Icons.directions_car_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.offWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left Accent Bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Decorative Circle Top-Right
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.06),
              ),
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row
                Row(
                  children: [
                    // Best Value Badge
                    if (plan.isBestValue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '⭐ ${AppLocalizations.of(context)!.bestValue}',
                          style: TextStyle(
                            color: context.colors.offWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.companyName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: context.colors.darkText,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          plan.companyEn,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreenContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExcludeSemantics(
                        child: Icon(
                          _getIcon(plan.iconType),
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: Color(0xFFE2E8F0),
                  ), // slate200
                ),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(context, AppLocalizations.of(context)!.claimsDurationLabel, plan.claimsDuration),
                    _buildStatItem(context, AppLocalizations.of(context)!.coverageLabel, plan.coverage),
                    _buildStatItem(context, AppLocalizations.of(context)!.premiumLabel, plan.premium),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Row
                Row(
                  children: [
                    // Toggle
                    Row(
                      children: [
                        Switch(
                          value: plan.isBestValue,
                          onChanged: onToggleBestValue,
                          activeColor: AppColors.primaryGreen,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.bestValue,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.darkText,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Delete
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: onDelete,
                    ),
                    const SizedBox(width: 8),
                    // Edit
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: AppColors.primaryGreen,
                      onTap: onEdit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: context.colors.slate500,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExcludeSemantics(child: Icon(icon, color: color, size: 20)),
      ),
    );
  }
}
