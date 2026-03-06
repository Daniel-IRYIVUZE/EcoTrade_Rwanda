import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../utils/formatters.dart';
import '../../utils/date_utils.dart';

class CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final VoidCallback? onTap;
  const CollectionCard({super.key, required this.collection, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = collection.status == 'completed' ? Colors.green
        : collection.status == 'enRoute' ? Colors.blue : Colors.orange;
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
              width: 48, height: 48,
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.local_shipping, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(collection.hotelName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(collection.wasteType, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              Text(AppDateUtils.formatDateTime(collection.scheduledTime), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(AppFormatters.weight(collection.scheduledVolume), style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(collection.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
