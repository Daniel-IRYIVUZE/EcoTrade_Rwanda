import 'package:flutter/material.dart';
class LiveTrackingWidget extends StatelessWidget {
  const LiveTrackingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(height: 220, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_shipping, size: 48, color: Color(0xFF0F4C3A)), SizedBox(height: 8), Text('Driver is 2.3 km away', style: TextStyle(fontWeight: FontWeight.bold)), Text('Estimated arrival: 12 min', style: TextStyle(color: Color(0xFF6B7280)))])));
  }
}

