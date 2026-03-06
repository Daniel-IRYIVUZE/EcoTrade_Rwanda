import 'package:flutter/material.dart';

class RecyclerBidsScreen extends StatefulWidget {
  const RecyclerBidsScreen({super.key});
  @override
  State<RecyclerBidsScreen> createState() => _RecyclerBidsScreenState();
}
class _RecyclerBidsScreenState extends State<RecyclerBidsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bids'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, bottom: TabBar(controller: TabController(length: 3, vsync: Scrollable.of(context) as TickerProvider), tabs: const [Tab(text: 'Active'), Tab(text: 'Won'), Tab(text: 'Lost')], labelColor: Colors.white, indicatorColor: const Color(0xFF10B981))),
      body: DefaultTabController(length: 3, child: Column(children: [
        const TabBar(tabs: [Tab(text: 'Active'), Tab(text: 'Won'), Tab(text: 'Lost')], labelColor: Color(0xFF0F4C3A), indicatorColor: Color(0xFF0F4C3A)),
        Expanded(child: TabBarView(children: [
          _buildBidList('active'),
          _buildBidList('won'),
          _buildBidList('lost'),
        ])),
      ])),
    );
  }
  Widget _buildBidList(String status) {
    final items = [
      {'hotel': 'Marriott Hotel', 'type': 'UCO', 'amount': 45000, 'status': status},
      {'hotel': 'Serena Hotel', 'type': 'Glass', 'amount': 12000, 'status': status},
    ];
    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (_, i) {
      final b = items[i];
      return Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.gavel, color: Colors.white, size: 18)),
        title: Text(b['hotel'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(b['type'].toString()),
        trailing: Text('RWF ${b['amount']}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
      ));
    });
  }
}
