import 'package:flutter/material.dart';
class DriverMapView extends StatelessWidget {
  const DriverMapView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(height: 300, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 48, color: Color(0xFF0F4C3A)), Text('Fleet Map View')])));
  }
}
