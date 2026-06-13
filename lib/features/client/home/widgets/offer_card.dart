// PATH: lib/features/client/home/widgets/offer_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../shared/domain/models/plan_model.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class OfferCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback? onTap;

  const OfferCard({
    super.key,
    required this.plan,
    this.onTap,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'verified':
        return Icons.verified_rounded;
      case 'automobile':
        return Icons.directions_car_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'commercial':
      case 'industrial':
        return Icons.business_rounded;
      case 'professional':
        return Icons.work_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final locale = AppLocalizations.of(context)!.localeName;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 220,
          height: 260,
          decoration: BoxDecoration(
            color: context.colors.offWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Subtle Green Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // TOP SECTION (Green Header)
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                    ),
                    child: Stack(
                      children: [
                        // Decorative Circle 1 (Large Top-Right)
                        Positioned(
                          top: -30,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.offWhite.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        // Decorative Circle 2 (Small Bottom-Left)
                        Positioned(
                          bottom: 5,
                          left: 10,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.offWhite.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        // Center Icon
                        Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: context.colors.offWhite,
                              shape: BoxShape.circle,
                            ),
                            child: ExcludeSemantics(
                              child: Icon(
                                _getIcon(plan.iconType),
                                color: AppColors.primaryGreen,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        // Operator Badge (Top-Left in RTL)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: plan.operatorColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  plan.operatorCode == 'TAKAFUL' ? Icons.nightlight_round : Icons.shield,
                                  size: 10,
                                  color: plan.operatorCode == 'TAKAFUL' ? context.colors.offWhite : Color(0xFF2ECC71),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  plan.operatorNameAr,
                                  style: TextStyle(
                                    color: plan.operatorCode == 'TAKAFUL' ? context.colors.offWhite : Color(0xFF2ECC71),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Best Value Badge (Top-Right)
                        if (plan.isBestValue)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.goldAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '⭐ الأفضل',
                                style: TextStyle(
                                  color: context.colors.offWhite,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // BOTTOM SECTION (Content)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.getName(locale),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.colors.darkText,
                              fontFamily: 'Cairo',
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            plan.getPriceNote(locale),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colors.slate500,
                              fontFamily: 'Cairo',
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const Spacer(),
                          // Price Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                ' ${AppLocalizations.of(context)!.dzd}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryGreenLight,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                plan.basePrice.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.fromLastMonth.split(' ').first, // Hacky "From"
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.slate500,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Subscribe Button
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldAccent,
                                foregroundColor: context.colors.offWhite,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const ExcludeSemantics(
                                    child: Icon(Icons.arrow_back_ios_rounded, size: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.subscribeNow,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // DIAGONAL "جديد" RIBBON (Top-Left)
              if (plan.isBestValue)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Transform.rotate(
                    angle: -math.pi / 4,
                    origin: const Offset(-25, -5),
                    child: Container(
                      width: 100,
                      height: 24,
                      color: AppColors.goldAccent,
                      alignment: Alignment.center,
                      child: Text(
                        'جديد',
                        style: TextStyle(
                          color: context.colors.offWhite,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
