import 'package:flutter/material.dart';
class BidDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bid;
  const BidDetailsScreen({super.key, required this.bid});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bid Details'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bid from ${bid['recycler'] ?? 'Recycler'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          ...[('Amount', 'RWF ${bid['amount'] ?? 0}'), ('Waste Type', bid['wasteType'] ?? 'UCO'), ('Volume', '${bid['volume'] ?? 0} kg'), ('Pickup Date', bid['pickupDate'] ?? 'TBD'), ('Status', bid['status'] ?? 'Pending')].map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.$1, style: const TextStyle(color: Color(0xFF6B7280))), Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w500))]))),
        ]))),
      ]),
    );
  }
}

