// lib/features/operator/algeria_takaful/dashboard/widgets/at_line_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';

class AtLineChart extends StatelessWidget {
  const AtLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final spots = [
      const FlSpot(1, 3),
      const FlSpot(2, 7),
      const FlSpot(3, 5),
      const FlSpot(4, 12),
      const FlSpot(5, 9),
      const FlSpot(6, 15),
      const FlSpot(7, 18),
      const FlSpot(8, 14),
      const FlSpot(9, 22),
      const FlSpot(10, 19),
      const FlSpot(11, 27),
      const FlSpot(12, 24),
    ];

    final paidSpots = [
      const FlSpot(1, 1),
      const FlSpot(2, 3),
      const FlSpot(3, 2),
      const FlSpot(4, 6),
      const FlSpot(5, 4),
      const FlSpot(6, 8),
      const FlSpot(7, 10),
      const FlSpot(8, 7),
      const FlSpot(9, 14),
      const FlSpot(10, 11),
      const FlSpot(11, 18),
      const FlSpot(12, 16),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: kGoldDeep, size: 18),
              const SizedBox(width: 8),
              Text(
                'الاشتراكات الشهرية',
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kGoldDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => const FlLine(
                    color: kParchment,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, meta) => Text(
                        v.toInt().toString(),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10,
                          color: kInkMuted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        const months = ['ج', 'ف', 'م', 'أ', 'م', 'ج',
                            'ج', 'أ', 'س', 'أ', 'ن', 'د'];
                        final idx = v.toInt() - 1;
                        if (idx < 0 || idx >= months.length) return const SizedBox();
                        return Text(
                          months[idx],
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 10,
                            color: kInkMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Main line (total subscriptions) -> kGoldDeep
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: kGoldDeep,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          kGoldDeep.withValues(alpha: 0.15),
                          kGoldDeep.withValues(alpha: 0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Dashed line (paid) -> kGoldLight
                  LineChartBarData(
                    spots: paidSpots,
                    isCurved: true,
                    color: kGoldLight,
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                    dashArray: const [5, 4],
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: kGoldDeep, label: 'إجمالي الاشتراكات'),
              const SizedBox(width: 24),
              _LegendItem(color: kGoldLight, label: 'الاشتراكات المدفوعة', dashed: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(2),
            border: dashed ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 11,
            color: kInkMuted,
          ),
        ),
      ],
    );
  }
}
