import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const EarningsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final labels = ['M','T','W','T','F','S','S'];
            final i = v.toInt();
            return i >= 0 && i < labels.length ? Text(labels[i], style: const TextStyle(fontSize: 10)) : const Text('');
          },
        )),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['amount'] as num).toDouble())).toList(),
          isCurved: true,
          color: const Color(0xFF10B981),
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: const Color(0xFF10B981).withValues(alpha: 0.1)),
        ),
      ],
    ));
  }
}
