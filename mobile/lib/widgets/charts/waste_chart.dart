import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WasteChart extends StatelessWidget {
  final Map<String, double> wasteData;
  const WasteChart({super.key, required this.wasteData});

  static const _colors = [Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6)];

  @override
  Widget build(BuildContext context) {
    final entries = wasteData.entries.toList();
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            return i >= 0 && i < entries.length ? Text(entries[i].key, style: const TextStyle(fontSize: 9)) : const Text('');
          },
        )),
      ),
      barGroups: entries.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(toY: e.value.value, color: _colors[e.key % _colors.length], width: 20, borderRadius: BorderRadius.circular(4))],
      )).toList(),
    ));
  }
}
