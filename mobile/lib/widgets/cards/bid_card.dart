import 'package:flutter/material.dart';
import '../../models/bid_model.dart';
import '../../utils/formatters.dart';
import '../../utils/date_utils.dart';

class BidCardWidget extends StatelessWidget {
  final BidModel bid;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool showActions;

  const BidCardWidget({super.key, required this.bid, this.onAccept, this.onReject, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    final statusColor = bid.status == 'accepted' ? Colors.green
        : bid.status == 'rejected' ? Colors.red : Colors.orange;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(bid.recyclerCompany, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(bid.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(AppFormatters.currency(bid.amount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F4C3A))),
          const SizedBox(height: 4),
          Text(AppDateUtils.timeAgo(bid.createdAt), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
          if (bid.message != null) ...[
            const SizedBox(height: 8),
            Text(bid.message!, style: const TextStyle(color: Color(0xFF374151))),
          ],
          if (showActions && bid.status == 'pending') ...[
            const Divider(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onReject, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Reject'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A)), child: const Text('Accept'))),
            ]),
          ],
        ]),
      ),
    );
  }
}

// Alias for backward compat
typedef BidCardWidgetAlias = BidCardWidget;
