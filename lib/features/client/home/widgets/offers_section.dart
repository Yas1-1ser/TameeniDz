// PATH: lib/features/client/home/widgets/offers_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import '../../../shared/data/plan_repository.dart';
import '../../../shared/domain/models/plan_model.dart';
import 'offer_card.dart';
import '../../../../core/router/app_routes.dart';

class OffersSection extends ConsumerStatefulWidget {
  const OffersSection({super.key});

  @override
  ConsumerState<OffersSection> createState() => _OffersSectionState();
}

class _OffersSectionState extends ConsumerState<OffersSection> with SingleTickerProviderStateMixin {
  String _selectedFilter = '🌟 الكل';

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER ROW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.plans),
                child: const Text(
                  'عرض الكل ←',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'العروض المتاحة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.colors.darkText,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'اختر الخطة المناسبة لك',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.slate500,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const ExcludeSemantics(
                      child: Icon(Icons.local_offer_rounded, color: AppColors.goldAccent, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // DECORATIVE DIVIDER
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 1.5,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [AppColors.primaryGreen, AppColors.primaryGreen.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),

        // FILTER CHIPS ROW
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildFilterChip('🌟 الكل'),
              const SizedBox(width: 10),
              _buildFilterChip('💰 الأرخص'),
              const SizedBox(width: 10),
              _buildFilterChip('🏆 الأفضل قيمة'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // OFFERS HORIZONTAL LIST with AnimatedSwitcher
        SizedBox(
          height: 270,
          child: plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) return _buildEmptyState();

              final filteredPlans = _getSortedPlans(plans);

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: ListView.separated(
                  key: ValueKey(_selectedFilter), // Force rebuild for animation
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredPlans.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return OfferCard(
                      plan: filteredPlans[index],
                      onTap: () => context.push(AppRoutes.plans),
                    );
                  },
                ),
              );
            },
            loading: () => _buildLoadingState(),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "تعذر تحميل الخطط، يرجى المحاولة لاحقاً",
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(plansStreamProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('إعادة المحاولة', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 34,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryGreen 
              : AppColors.primaryGreenContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? null 
              : Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? context.colors.offWhite : AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  List<PlanModel> _getSortedPlans(List<PlanModel> plans) {
    var list = [...plans];
    if (_selectedFilter == '🏆 الأفضل قيمة') {
      list.sort((a, b) {
        if (a.isBestValue && !b.isBestValue) return -1;
        if (!a.isBestValue && b.isBestValue) return 1;
        
        // Secondary sort: base_price DESC
        final priceA = a.basePrice;
        final priceB = b.basePrice;
        return priceB.compareTo(priceA);
      });
    } else if (_selectedFilter == '💰 الأرخص') {
      list.sort((a, b) {
        final priceA = a.basePrice;
        final priceB = b.basePrice;
        return priceA.compareTo(priceB);
      });
    }
    return list;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.inbox_rounded, size: 48, color: AppColors.primaryGreenLight),
          ),
          SizedBox(height: 8),
          Text(
            'لا توجد عروض متاحة حالياً',
            style: TextStyle(
              color: context.colors.slate500,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 2,
      separatorBuilder: (context, index) => const SizedBox(width: 14),
      itemBuilder: (context, index) => const _CustomShimmerCard(),
    );
  }
}

class _CustomShimmerCard extends StatefulWidget {
  const _CustomShimmerCard();

  @override
  State<_CustomShimmerCard> createState() => _CustomShimmerCardState();
}

class _CustomShimmerCardState extends State<_CustomShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _colorAnimation = ColorTween(
      begin: const Color(0xFFE2E8F0),
      end: const Color(0xFFF8FAFC),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: 220,
          height: 260,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }
}
