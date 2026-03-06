import 'package:flutter/material.dart';

class TurnByTurnWidget extends StatelessWidget {
  final String instruction;
  final double distance;
  final IconData icon;
  const TurnByTurnWidget({super.key, required this.instruction, required this.distance, this.icon = Icons.straight});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0F4C3A),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(instruction, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text('In ${distance.toStringAsFixed(0)} m', style: const TextStyle(color: Colors.white70)),
        ])),
      ]),
    );
  }
}


