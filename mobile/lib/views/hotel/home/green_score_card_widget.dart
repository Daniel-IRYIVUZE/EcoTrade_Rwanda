import 'package:flutter/material.dart';
class GreenScoreCardWidget extends StatelessWidget {
  final int score;
  const GreenScoreCardWidget({super.key, required this.score});
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      CircleAvatar(radius: 32, backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1), child: Text('$score', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF10B981)))),
      const SizedBox(width: 16),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Green Score', style: TextStyle(fontWeight: FontWeight.bold)), Text('Level: Gold Partner', style: TextStyle(color: Color(0xFF6B7280))), LinearProgressIndicator(value: 0.75, color: Color(0xFF10B981), backgroundColor: Color(0xFFF3F4F6), minHeight: 6, borderRadius: BorderRadius.all(Radius.circular(3)))])),
    ])));
  }
}

