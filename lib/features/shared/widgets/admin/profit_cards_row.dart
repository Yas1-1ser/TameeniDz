import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/utils/number_utils.dart';

class ProfitCardsRow extends StatelessWidget {
  final double todayProfit;
  final double monthProfit;
  final double totalProfit;
  final double todayTrend;
  final double monthTrend;

  const ProfitCardsRow({
    super.key,
    required this.todayProfit,
    required this.monthProfit,
    required this.totalProfit,
    this.todayTrend = 8.0,
    this.monthTrend = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final nf = safeNumberFormat(context);

    final cards = [
      {
        'icon': '💰',
        'label': AppLocalizations.of(context)!.todayProfit,
        'value': todayProfit,
        'trend': todayTrend,
        'trendLabel': AppLocalizations.of(context)!.yesterday,
      },
      {
        'icon': '📅',
        'label': AppLocalizations.of(context)!.monthProfit,
        'value': monthProfit,
        'trend': monthTrend,
        'trendLabel': AppLocalizations.of(context)!.lastMonth,
      },
      {
        'icon': '📊',
        'label': AppLocalizations.of(context)!.allTimeProfit,
        'value': totalProfit,
        'trend': null,
        'trendLabel': AppLocalizations.of(context)!.sinceLaunch,
      },
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final card = cards[i];
          final trend = card['trend'] as double?;
          final isPositive = (trend ?? 0) >= 0;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + i * 150),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Opacity(
                opacity: val,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - val)),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2634), Color(0xFF0A0E1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['icon'] as String,
                        style: const TextStyle(fontSize: 22),
                      ),
                      if (trend != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (isPositive ? Colors.green : Colors.red)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isPositive ? '↑' : '↓'} ${trend.abs()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  isPositive
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: card['value'] as double),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutQuart,
                        builder: (context, val, _) {
                          return Text(
                            nf.format(val.toInt()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          );
                        },
                      ),
                      Text(
                        card['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.offWhite.withValues(alpha: 0.54),
                        ),
                      ),
                      Text(
                        card['trendLabel'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.offWhite.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
