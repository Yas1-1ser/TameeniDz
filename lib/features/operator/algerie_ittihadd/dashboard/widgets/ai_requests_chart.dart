// lib/features/operator/algerie_ittihadd/dashboard/widgets/ai_requests_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';

class AiRequestsChart extends StatefulWidget {
  const AiRequestsChart({super.key});
  @override
  State<AiRequestsChart> createState() => _AiRequestsChartState();
}

class _AiRequestsChartState extends State<AiRequestsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;

  static const _kGreen  = AppColors.alIttihadGreen;
  static const _kLight  = Color(0xFF4CAF82);
  static const _months  = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                            'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 900.ms);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _loadData();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
      final rows = await Supabase.instance.client
          .from('policies')
          .select('status, submitted_at')
          .eq('operator_id', 'al_ittihad')
          .gte('submitted_at', sixMonthsAgo.toIso8601String());

      final Map<int, Map<String, int>> grouped = {};
      for (int i = 0; i < 6; i++) {
        final m = (now.month - 5 + i - 1) % 12 + 1;
        grouped[i] = {'pending': 0, 'accepted': 0, 'paid': 0, 'rejected': 0, 'month': m};
      }
      for (final row in rows) {
        final dt = DateTime.tryParse(row['submitted_at'] ?? '');
        if (dt == null) continue;
        final diff = (now.year * 12 + now.month) - (dt.year * 12 + dt.month);
        if (diff < 0 || diff > 5) continue;
        final idx = 5 - diff;
        final status = row['status'] as String? ?? 'pending';
        grouped[idx]?[status] = (grouped[idx]?[status] ?? 0) + 1;
      }
      if (mounted) {
        setState(() { _data = grouped.values.toList(); _loading = false; });
        _ctrl.forward();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _data = [
            {'pending': 6,  'accepted': 4, 'paid': 2, 'rejected': 1, 'month': 12},
            {'pending': 10, 'accepted': 7, 'paid': 5, 'rejected': 1, 'month': 1},
            {'pending': 8,  'accepted': 6, 'paid': 4, 'rejected': 1, 'month': 2},
            {'pending': 13, 'accepted': 9, 'paid': 8, 'rejected': 2, 'month': 3},
            {'pending': 11, 'accepted': 8, 'paid': 6, 'rejected': 1, 'month': 4},
            {'pending': 16, 'accepted': 12,'paid': 10,'rejected': 2, 'month': 5},
          ];
          _loading = false;
        });
        _ctrl.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChartCard(
          title: 'الطلبات الشهرية',
          icon: Icons.trending_up_rounded,
          accentColor: _kGreen,
          child: _loading
              ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2)))
              : AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => SizedBox(height: 160, child: LineChart(_buildLineData())),
                ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 16),

        _ChartCard(
          title: 'توزيع حالات الطلبات',
          icon: Icons.donut_large_rounded,
          accentColor: _kGreen,
          child: _loading
              ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2)))
              : _buildDonutSection(),
        ).animate().fadeIn(duration: 600.ms, delay: 150.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOut),
      ],
    );
  }

  LineChartData _buildLineData() {
    final totalSpots = _data.asMap().entries.map((e) {
      final total = (e.value['pending'] as int) + (e.value['accepted'] as int)
                  + (e.value['paid'] as int)    + (e.value['rejected'] as int);
      return FlSpot(e.key.toDouble(), total * _anim.value);
    }).toList();

    final paidSpots = _data.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), (e.value['paid'] as int) * _anim.value)).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: kParchment, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final idx = v.toInt();
            if (idx < 0 || idx >= _data.length) return const SizedBox();
            final m = (_data[idx]['month'] as int) - 1;
            return Text(_months[m].substring(0, 3),
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 10, color: kInkMuted));
          },
        )),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: totalSpots,
          isCurved: true,
          color: _kGreen,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [_kGreen.withValues(alpha: 0.18), _kGreen.withValues(alpha: 0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
        LineChartBarData(
          spots: paidSpots,
          isCurved: true,
          color: _kLight,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          dashArray: [4, 4],
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => _kGreen,
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            '${s.y.toInt()} طلب',
            GoogleFonts.ibmPlexSansArabic(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildDonutSection() {
    if (_data.isEmpty) return const SizedBox.shrink();
    int totalPending = 0, totalAccepted = 0, totalPaid = 0, totalRejected = 0;
    for (final d in _data) {
      totalPending  += d['pending']  as int;
      totalAccepted += d['accepted'] as int;
      totalPaid     += d['paid']     as int;
      totalRejected += d['rejected'] as int;
    }
    if (totalPending + totalAccepted + totalPaid + totalRejected == 0) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return Row(children: [
      Expanded(flex: 5, child: SizedBox(height: 130, child: PieChart(PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 35,
        sections: [
          PieChartSectionData(value: totalPaid.toDouble(),     color: _kGreen,          radius: 28, showTitle: false),
          PieChartSectionData(value: totalAccepted.toDouble(), color: _kLight,           radius: 24, showTitle: false),
          PieChartSectionData(value: totalPending.toDouble(),  color: const Color(0xFF8BC4A8), radius: 22, showTitle: false),
          PieChartSectionData(value: totalRejected.toDouble(), color: Colors.redAccent, radius: 20, showTitle: false),
        ],
      )))),
      const SizedBox(width: 16),
      Expanded(flex: 6, child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(color: _kGreen,                    label: 'مدفوع',         count: totalPaid),
          _Legend(color: _kLight,                    label: 'مقبول',         count: totalAccepted),
          _Legend(color: const Color(0xFF8BC4A8),    label: 'قيد المراجعة', count: totalPending),
          _Legend(color: Colors.redAccent,           label: 'مرفوض',         count: totalRejected),
        ],
      )),
    ]);
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;
  const _ChartCard({required this.title, required this.icon, required this.accentColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kParchment),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 16, color: accentColor)),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _Legend({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: kInkMuted))),
        Text('$count', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.bold, color: kInk)),
      ]),
    );
  }
}
