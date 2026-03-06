import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class CollectionsBoard extends StatefulWidget {
  const CollectionsBoard({super.key});
  @override
  State<CollectionsBoard> createState() => _CollectionsBoardState();
}

class _CollectionsBoardState extends State<CollectionsBoard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _collections = [
    {'id': 'COL-001', 'hotel': 'Marriott Hotel', 'type': 'UCO', 'volume': '120 kg', 'driver': 'Jean Claude', 'driverPhone': '+250 788 001 001', 'time': 'Today 10:00 AM', 'status': 'assigned', 'address': 'KG 7 Ave, Kigali'},
    {'id': 'COL-002', 'hotel': 'Serena Hotel', 'type': 'Glass', 'volume': '80 kg', 'driver': 'Marie Claire', 'driverPhone': '+250 788 002 002', 'time': 'Today 11:30 AM', 'status': 'assigned', 'address': 'KN 3 Rd, Kigali'},
    {'id': 'COL-003', 'hotel': 'Radisson Blu', 'type': 'Cardboard', 'volume': '200 kg', 'driver': 'David Nkurunziza', 'driverPhone': '+250 788 003 003', 'time': 'Today 09:15 AM', 'status': 'in_progress', 'address': 'KG 2 Ave, Kigali'},
    {'id': 'COL-004', 'hotel': 'Kigali Marriott', 'type': 'UCO', 'volume': '90 kg', 'driver': 'Alice Mutesi', 'driverPhone': '+250 788 004 004', 'time': 'Today 08:00 AM', 'status': 'in_progress', 'address': 'KN 5 Rd, Kigali'},
    {'id': 'COL-005', 'hotel': 'Lemigo Hotel', 'type': 'Plastic', 'volume': '60 kg', 'driver': 'Jean Claude', 'driverPhone': '+250 788 001 001', 'time': 'Yesterday 03:00 PM', 'status': 'completed', 'address': 'KG 9 Ave, Kigali'},
    {'id': 'COL-006', 'hotel': 'Mille Collines', 'type': 'Glass', 'volume': '45 kg', 'driver': 'Marie Claire', 'driverPhone': '+250 788 002 002', 'time': 'Yesterday 01:00 PM', 'status': 'completed', 'address': 'KN 7 Ave, Kigali'},
  ];

  final List<String> _availableDrivers = ['Jean Claude', 'Marie Claire', 'David Nkurunziza', 'Alice Mutesi'];

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

  List<Map<String, dynamic>> _byStatus(String s) => _collections.where((c) => c['status'] == s).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Collections Board', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Assigned (${_byStatus('assigned').length})'),
            Tab(text: 'In Progress (${_byStatus('in_progress').length})'),
            Tab(text: 'Completed (${_byStatus('completed').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBoard('assigned', Colors.blue),
          _buildBoard('in_progress', Colors.orange),
          _buildBoard('completed', Colors.green),
        ],
      ),
    );
  }

  Widget _buildBoard(String status, Color color) {
    final items = _byStatus(status);
    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('No ${ status == 'in_progress' ? 'in-progress' : status} collections', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildCollectionCard(items[i], color),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> c, Color statusColor) {
    final status = c['status'] as String;
    final isAssigned = status == 'assigned';
    final isInProgress = status == 'in_progress';
    final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: isInProgress ? Border.all(color: Colors.orange.withValues(alpha: 0.4), width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.local_shipping, color: statusColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['hotel'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(c['id'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                isInProgress ? 'In Progress' : isAssigned ? 'Assigned' : 'Done',
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _infoChip(Icons.eco, c['type'] as String),
                _infoChip(Icons.monitor_weight, c['volume'] as String),
                _infoChip(Icons.schedule, c['time'].toString().split(' ').last),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(c['address'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: AppColors.primary, size: 14),
            ),
            const SizedBox(width: 8),
            Text(c['driver'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (isAssigned) ...[
              TextButton(
                onPressed: () => _showReassignDialog(c),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 28), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Reassign', style: TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _advanceStatus(c, 'in_progress'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
            if (isInProgress)
              ElevatedButton(
                onPressed: () => _advanceStatus(c, 'completed'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Mark Done', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            if (isCompleted)
              TextButton.icon(
                onPressed: () => _showReceipt(c),
                icon: const Icon(Icons.receipt_long, size: 14, color: AppColors.secondary),
                label: const Text('Receipt', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(70, 28), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
          ]),
        ]),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(children: [
    Icon(icon, size: 12, color: AppColors.textSecondary),
    const SizedBox(width: 3),
    Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
  ]);

  void _advanceStatus(Map<String, dynamic> c, String newStatus) {
    setState(() => c['status'] = newStatus);
    final msg = newStatus == 'in_progress' ? 'Collection started!' : 'Collection marked as complete!';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: newStatus == 'completed' ? Colors.green : Colors.blue, behavior: SnackBarBehavior.floating));
  }

  void _showReassignDialog(Map<String, dynamic> c) {
    String? selectedDriver = c['driver'] as String;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reassign Driver'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Collection: ${c['hotel']}', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedDriver,
            decoration: InputDecoration(labelText: 'Select Driver', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            items: _availableDrivers.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setDialogState(() => selectedDriver = v),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => c['driver'] = selectedDriver);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reassigned to $selectedDriver'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _showReceipt(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Colors.green, size: 28)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Collection Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(c['id'] as String, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 20),
          _receiptRow('Hotel', c['hotel'] as String),
          _receiptRow('Waste Type', c['type'] as String),
          _receiptRow('Volume Collected', c['volume'] as String),
          _receiptRow('Driver', c['driver'] as String),
          _receiptRow('Completed', c['time'] as String),
          _receiptRow('Status', 'Verified ✓'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export coming soon'), backgroundColor: AppColors.primary)); },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
    );
  }

  Widget _receiptRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );
}
