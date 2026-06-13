import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AdminDashboardChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const AdminDashboardChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: context.colors.beigeCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noData,
            style: TextStyle(
              color: context.colors.slate500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final Color primaryColor = const Color(0xFF2D1F0E); // Dark Brown
    final Color accentColor = const Color(0xFFC9A96E); // Gold

    // Convert data to FlSpot list
    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['value'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    // Find max value for Y axis scaling
    double maxY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }
    maxY = maxY > 0 ? (maxY * 1.2).ceilToDouble() : 1000.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFFE5DDD0).withValues(alpha: 0.5),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${(value / 1000).toStringAsFixed(1)}k',
                      style: const TextStyle(
                        color: Color(0xFF8B7355),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
                reservedSize: 36,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data[index]['month'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF8B7355),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: context.colors.surface,
                    strokeWidth: 2,
                    strokeColor: accentColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.1),
                    primaryColor.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => primaryColor.withValues(alpha: 0.9),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(0)} DZD',
                    TextStyle(
                      color: context.colors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
