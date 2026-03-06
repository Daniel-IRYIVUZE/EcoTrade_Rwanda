import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GreenScoreChart extends StatelessWidget {
  final double score;
  final double maxScore;
  const GreenScoreChart({super.key, required this.score, this.maxScore = 100});

  @override
  Widget build(BuildContext context) {
    final pct = (score / maxScore).clamp(0.0, 1.0);
    return PieChart(PieChartData(
      sectionsSpace: 0,
      centerSpaceRadius: 40,
      sections: [
        PieChartSectionData(value: pct * 100, color: const Color(0xFF10B981), radius: 20, showTitle: false),
        PieChartSectionData(value: (1 - pct) * 100, color: const Color(0xFFE5E7EB), radius: 20, showTitle: false),
      ],
    ));
  }
}
