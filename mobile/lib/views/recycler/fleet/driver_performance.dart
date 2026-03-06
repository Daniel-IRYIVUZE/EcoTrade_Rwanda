import 'package:flutter/material.dart';
class DriverPerformance extends StatelessWidget {
  final Map<String, dynamic> driver;
  const DriverPerformance({super.key, required this.driver});
  @override
  Widget build(BuildContext context) {
    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(driver['name'] ?? 'Driver', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ...[('Collections', '${driver['collections'] ?? 0}'), ('Rating', '${driver['rating'] ?? 5.0} ★'), ('On-time Rate', '${driver['ontime'] ?? 95}%')].map((m) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(m.$1, style: const TextStyle(color: Color(0xFF6B7280))), Text(m.$2, style: const TextStyle(fontWeight: FontWeight.w500))]))),
    ])));
  }
}
