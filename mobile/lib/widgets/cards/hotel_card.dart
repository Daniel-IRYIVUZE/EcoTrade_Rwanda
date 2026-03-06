import 'package:flutter/material.dart';
import '../../models/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback? onTap;
  const HotelCard({super.key, required this.hotel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: const Color(0xFF0F4C3A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.hotel, color: Color(0xFF0F4C3A)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(hotel.location.address ?? 'No address', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                const Icon(Icons.eco, size: 14, color: Color(0xFF10B981)),
                Text(' ${hotel.greenScore.toStringAsFixed(0)} pts', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
              ]),
            ])),
            Row(children: List.generate(hotel.starRating, (_) => const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)))),
          ]),
        ),
      ),
    );
  }
}
