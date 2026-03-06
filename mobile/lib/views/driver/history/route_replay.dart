import 'package:flutter/material.dart';

class RouteReplayWidget extends StatelessWidget {
  const RouteReplayWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.replay, size: 48, color: Color(0xFF0F4C3A)),
        SizedBox(height: 8),
        Text('Route replay coming soon', style: TextStyle(color: Color(0xFF6B7280))),
      ]),
    );
  }
}


