// lib/features/operator/algeria_takaful/dashboard/widgets/at_bar_chart.dart
import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';

class AtBarChart extends StatefulWidget {
  const AtBarChart({super.key});

  @override
  State<AtBarChart> createState() => _AtBarChartState();
}

class _AtBarChartState extends State<AtBarChart> {
  int _touchedBarIndex = -1;

  BarChartGroupData _barGroup(int x, double claims, double surplus) {
    final isTouched = x == _touchedBarIndex;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: claims,
          color: isTouched ? kGoldDeep : kGoldDeep.withValues(alpha: 0.8),
          width: isTouched ? 13 : 10,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: surplus,
          color: isTouched ? kGoldLight : kGoldLight.withValues(alpha: 0.8),
          width: isTouched ? 13 : 10,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      barsSpace: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.bar_chart_rounded, color: kGoldDeep, size: 18),
              const SizedBox(width: 8),
              Text(
                'التعويضات مقابل الفائض',
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kGoldDeep,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedBarIndex =
                          response?.spot?.touchedBarGroupIndex ?? -1;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => kGoldDeep,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      '${rod.toY.toInt()} وثيقة',
                      GoogleFonts.ibmPlexSansArabic(
                        color: context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        const quarters = ['ر1', 'ر2', 'ر3', 'ر4'];
                        final idx = v.toInt();
                        if (idx < 0 || idx >= quarters.length) {
                          return const SizedBox();
                        }
                        return Text(
                          quarters[idx],
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            color: kInkMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, meta) => Text(
                        v.toInt().toString(),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 9,
                          color: kInkMuted,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => const FlLine(
                    color: kParchment,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _barGroup(0, 12, 8),
                  _barGroup(1, 18, 11),
                  _barGroup(2, 15, 9),
                  _barGroup(3, 22, 16),
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
              _LegendItem(color: kGoldDeep, label: 'المطالبات'),
              const SizedBox(width: 24),
              _LegendItem(color: kGoldLight, label: 'الفائض'),
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

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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
