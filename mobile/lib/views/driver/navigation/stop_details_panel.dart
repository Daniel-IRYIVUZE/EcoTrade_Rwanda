import 'package:flutter/material.dart';

class StopDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> stop;
  final VoidCallback onArrive;
  const StopDetailsPanel({super.key, required this.stop, required this.onArrive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        Row(children: [
          const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.hotel, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stop['hotel'] ?? 'Hotel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(stop['address'] ?? '', style: const TextStyle(color: Color(0xFF6B7280))),
          ])),
          Text('${stop['distance'] ?? '0.5'} km', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C3A))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: onArrive, icon: const Icon(Icons.flag, size: 16), label: const Text('I Arrived'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white))),
        ]),
      ]),
    );
  }
}


