import 'package:flutter/material.dart';
export 'green_score_page.dart';

class GreenScoreBreakdown extends StatelessWidget {
  const GreenScoreBreakdown({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), child: Column(children: [const Text('Score Breakdown', style: TextStyle(fontWeight: FontWeight.bold)), ...[('Collections', 300), ('Listings', 200), ('Ratings', 150)].map((item) => ListTile(title: Text(item.$1), trailing: Text('+${item.$2} pts', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))))]));
  }
}

