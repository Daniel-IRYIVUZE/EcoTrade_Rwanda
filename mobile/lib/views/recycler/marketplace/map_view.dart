import 'package:flutter/material.dart';
class MapView extends StatelessWidget {
  const MapView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF3F4F6), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 64, color: Color(0xFF0F4C3A)), Text('Waste Locations Map')])));
  }
}
