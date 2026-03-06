import 'package:flutter/material.dart';

class RouteSummaryCard extends StatelessWidget {
  final int totalStops;
  final int completedStops;
  final double totalDistance;
  final bool isStarted;
  const RouteSummaryCard({super.key, required this.totalStops, required this.completedStops, required this.totalDistance, required this.isStarted});
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Route Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isStarted ? Colors.green.shade100 : Colors.orange.shade100, borderRadius: BorderRadius.circular(20)), child: Text(isStarted ? 'In Progress' : 'Not Started', style: TextStyle(color: isStarted ? Colors.green.shade800 : Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 12),
      LinearProgressIndicator(value: totalStops > 0 ? completedStops / totalStops : 0, backgroundColor: const Color(0xFFF3F4F6), color: const Color(0xFF0F4C3A), minHeight: 8, borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _stat('$completedStops/$totalStops', 'Stops'),
        _stat('${totalDistance.toStringAsFixed(1)} km', 'Distance'),
        _stat('${(totalDistance * 3).toInt()} min', 'Est. Time'),
      ]),
    ])));
  }
  Widget _stat(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))]);
}


