import 'package:flutter/material.dart';
import '../../models/waste_listing_model.dart';
import '../../utils/formatters.dart';

class ListingCard extends StatelessWidget {
  final WasteListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onBid;

  const ListingCard({super.key, required this.listing, this.onTap, this.onBid});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(listing.hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(listing.status.toUpperCase(), style: const TextStyle(color: Color(0xFF10B981), fontSize: 11)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.delete_outline, size: 15, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(listing.wasteType, style: const TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(width: 16),
              const Icon(Icons.scale, size: 15, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(AppFormatters.weight(listing.volume), style: const TextStyle(color: Color(0xFF6B7280))),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(AppFormatters.currency(listing.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F4C3A))),
              if (onBid != null)
                ElevatedButton(
                  onPressed: onBid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C3A),
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Bid', style: TextStyle(fontSize: 13)),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}
