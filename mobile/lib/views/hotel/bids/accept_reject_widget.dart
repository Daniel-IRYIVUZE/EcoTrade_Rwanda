import 'package:flutter/material.dart';
class AcceptRejectWidget extends StatelessWidget {
  final String bidId;
  final double amount;
  final String recyclerName;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const AcceptRejectWidget({super.key, required this.bidId, required this.amount, required this.recyclerName, required this.onAccept, required this.onReject});
  @override
  Widget build(BuildContext context) {
    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(children: [const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.recycling, color: Colors.white, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(recyclerName, style: const TextStyle(fontWeight: FontWeight.bold)), Text('RWF ${amount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 18))]))]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: onReject, style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), child: const Text('Reject'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), child: const Text('Accept'))),
      ]),
    ])));
  }
}

