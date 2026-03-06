import 'package:flutter/material.dart';
class RevenueSummaryCard extends StatelessWidget {
  final double totalRevenue;
  final double monthlyRevenue;
  const RevenueSummaryCard({super.key, required this.totalRevenue, required this.monthlyRevenue});
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: const Color(0xFF0F4C3A), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Revenue', style: TextStyle(color: Colors.white70)),
      Text('RWF ${totalRevenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('This month: RWF ${monthlyRevenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
    ])));
  }
}

