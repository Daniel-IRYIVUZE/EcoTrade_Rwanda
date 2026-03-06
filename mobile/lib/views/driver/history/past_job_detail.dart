import 'package:flutter/material.dart';

class PastJobDetail extends StatelessWidget {
  final Map<String, dynamic> job;
  const PastJobDetail({super.key, required this.job});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(job['hotel'] ?? 'Hotel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _row(Icons.location_on, job['address'] ?? ''),
          _row(Icons.schedule, job['date'] ?? ''),
          _row(Icons.recycling, '${job['volume'] ?? 0} kg collected'),
          _row(Icons.monetization_on, 'RWF ${job['earnings'] ?? 0}'),
          _row(Icons.check_circle, job['status'] ?? 'Completed', color: Colors.green),
        ]))),
      ]),
    );
  }
  Widget _row(IconData icon, String text, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [Icon(icon, size: 16, color: color ?? const Color(0xFF6B7280)), const SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(color: color ?? const Color(0xFF374151))))]),
  );
}


