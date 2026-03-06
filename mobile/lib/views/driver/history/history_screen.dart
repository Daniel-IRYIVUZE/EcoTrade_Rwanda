import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});

  final _jobs = const [
    {'hotel': 'Marriott Hotel', 'type': 'UCO', 'volume': '120 kg', 'date': 'Today, 09:15 AM', 'earned': 15000, 'distance': '4.2 km', 'status': 'completed'},
    {'hotel': 'Serena Hotel', 'type': 'Glass', 'volume': '80 kg', 'date': 'Yesterday, 02:30 PM', 'earned': 8000, 'distance': '3.1 km', 'status': 'completed'},
    {'hotel': 'Radisson Blu', 'type': 'Cardboard', 'volume': '200 kg', 'date': 'Mar 4, 11:00 AM', 'earned': 12000, 'distance': '5.8 km', 'status': 'completed'},
    {'hotel': 'Kigali Marriott', 'type': 'Plastic', 'volume': '60 kg', 'date': 'Mar 3, 09:00 AM', 'earned': 6000, 'distance': '2.4 km', 'status': 'completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter coming soon')))),
        ],
      ),
      body: Column(children: [
        _buildSummaryBanner(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _jobs.length,
            itemBuilder: (_, i) => _buildJobCard(context, _jobs[i]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSummaryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF0e7490)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _sum('${_jobs.length}', 'Total Jobs'),
        _sum('RWF 41K', 'Total Earned'),
        _sum('15.5 km', 'Total Distance'),
      ]),
    );
  }

  Widget _sum(String val, String label) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(job['hotel'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text('${job['type']} • ${job['volume']} • ${job['distance']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(job['date'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('+ RWF ${job['earned']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          TextButton(
            onPressed: () => _showJobDetail(context, job),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 24), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Details', style: TextStyle(fontSize: 11, color: AppColors.primary)),
          ),
        ]),
      ]),
    );
  }

  void _showJobDetail(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Text(job['hotel'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _detail('Waste Type', job['type'] as String),
          _detail('Volume', job['volume'] as String),
          _detail('Date', job['date'] as String),
          _detail('Distance', job['distance'] as String),
          _detail('Earned', 'RWF ${job['earned']}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );
}
