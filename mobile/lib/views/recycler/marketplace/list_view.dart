import 'package:flutter/material.dart';
class MarketplaceListView extends StatelessWidget {
  final List<Map<String, dynamic>> listings;
  const MarketplaceListView({super.key, required this.listings});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: listings.length, itemBuilder: (_, i) {
      final l = listings[i];
      return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(title: Text(l['hotel']?.toString() ?? 'Hotel'), subtitle: Text('${l['type']} • ${l['volume']} kg'), trailing: Text('RWF ${l['price']}')));
    });
  }
}
