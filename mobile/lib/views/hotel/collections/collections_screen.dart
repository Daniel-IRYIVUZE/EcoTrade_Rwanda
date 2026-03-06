import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class HotelCollectionsScreen extends StatefulWidget {
  const HotelCollectionsScreen({super.key});
  @override
  State<HotelCollectionsScreen> createState() => _HotelCollectionsScreenState();
}

class _HotelCollectionsScreenState extends State<HotelCollectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _collections = [
    {'driver': 'Jean Pierre', 'type': 'UCO', 'volume': '120 kg', 'date': 'Today, 09:00 AM', 'status': 'upcoming', 'vehicle': 'RAD 123 B', 'recycler': 'GreenEnergy'},
    {'driver': 'Marie Claire', 'type': 'Glass', 'volume': '80 kg', 'date': 'Today, 02:00 PM', 'status': 'in_progress', 'vehicle': 'RAE 456 C', 'recycler': 'Kigali EcoPlant'},
    {'driver': 'David Nkurunziza', 'type': 'Cardboard', 'volume': '200 kg', 'date': 'Yesterday', 'status': 'completed', 'vehicle': 'RAF 789 D', 'recycler': 'Rwanda Recyclers'},
    {'driver': 'Alice Uwimana', 'type': 'Plastic', 'volume': '60 kg', 'date': '2 days ago', 'status': 'completed', 'vehicle': 'RAG 012 E', 'recycler': 'EcoWaste Solutions'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Collections', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'In Progress'), Tab(text: 'Completed')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['upcoming', 'in_progress', 'completed'].map(_buildList).toList(),
      ),
    );
  }

  Widget _buildList(String status) {
    final filtered = _collections.where((c) => c['status'] == status).toList();
    if (filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.local_shipping, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('No ${status.replaceAll('_', ' ')} collections', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildCard(filtered[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> col) {
    final status = col['status'] as String;
    final Color statusColor = status == 'in_progress' ? Colors.blue : status == 'completed' ? Colors.green : Colors.orange;
    final String statusLabel = status == 'in_progress' ? 'In Progress' : status == 'completed' ? 'Completed' : 'Scheduled';
    final IconData statusIcon = status == 'in_progress' ? Icons.directions_car : status == 'completed' ? Icons.check_circle : Icons.schedule;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: status == 'in_progress' ? Border.all(color: Colors.blue.shade200, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(statusIcon, color: statusColor, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${col['type']} Collection', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(col['date'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          _chip(Icons.person, col['driver'] as String),
          _chip(Icons.directions_car, col['vehicle'] as String),
          _chip(Icons.scale, col['volume'] as String),
        ]),
        if (status == 'in_progress') ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showTracking(context, col['driver'] as String),
            icon: const Icon(Icons.location_on, size: 16),
            label: const Text('Track Driver'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
        if (status == 'completed') ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _showRating(context, col['driver'] as String),
              icon: const Icon(Icons.star_outline, size: 16),
              label: const Text('Rate'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading receipt...'))),
              icon: const Icon(Icons.receipt_long, size: 16),
              label: const Text('Receipt'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
          ]),
        ],
      ]),
    );
  }

  Widget _chip(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );

  void _showTracking(BuildContext context, String driver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const Icon(Icons.location_on, color: Colors.blue, size: 48),
          const SizedBox(height: 12),
          Text('$driver is on the way!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Estimated arrival: 15 minutes', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  void _showRating(BuildContext context, String driver) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rate Driver'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(driver, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
            onTap: () => setS(() => rating = i + 1),
            child: Icon(i < rating ? Icons.star : Icons.star_outline, color: Colors.amber, size: 36),
          ))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rated $driver $rating ⭐'), backgroundColor: Colors.green)); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }
}
