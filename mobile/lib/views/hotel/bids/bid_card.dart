import 'package:flutter/material.dart';
class HotelBidCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  final VoidCallback? onTap;
  const HotelBidCard({super.key, required this.bid, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.gavel, color: Colors.white, size: 18)),
      title: Text(bid['recycler'] ?? 'Recycler', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${bid['wasteType'] ?? 'UCO'} • ${bid['volume'] ?? 0} kg'),
      trailing: Text('RWF ${bid['amount'] ?? 0}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
      onTap: onTap,
    ));
  }
}

