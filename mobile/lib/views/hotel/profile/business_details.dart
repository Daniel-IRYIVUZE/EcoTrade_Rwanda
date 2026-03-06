import 'package:flutter/material.dart';
class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Business Details'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Business Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Divider(), ...[('Business Name', 'Marriott Hotel Kigali'), ('RDB Registration', 'RDBKE202100001'), ('TIN Number', '101234567'), ('Star Rating', '★★★★★'), ('Location', 'KG 7 Ave, Kigali')].map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.$1, style: const TextStyle(color: Color(0xFF6B7280))), Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w500))])))])))]));
  }
}

