import 'package:flutter/material.dart';
class DashboardMetrics extends StatelessWidget {
  const DashboardMetrics({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5, children: [
      ...[('2.5 tons', 'Available', Icons.delete, Colors.blue), ('8', 'Active Bids', Icons.gavel, Colors.orange), ('5', 'Drivers', Icons.directions_car, Colors.green), ('12', 'Completed', Icons.check_circle, Colors.purple)].map((m) => Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(m.$3, color: m.$4), Text(m.$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(m.$2, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))]))))
    ]);
  }
}
