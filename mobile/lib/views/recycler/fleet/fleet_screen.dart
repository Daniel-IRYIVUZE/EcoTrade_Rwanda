import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../theme/colors.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});
  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _drivers = [
    {'name': 'Jean Claude', 'vehicle': 'RAD 123 B', 'phone': '+250 788 001 001', 'status': 'On Route', 'collections': 3, 'rating': 4.8, 'lat': -1.9441, 'lng': 30.0619, 'todayEarned': 45000, 'onTime': '95%'},
    {'name': 'Marie Claire', 'vehicle': 'RAE 456 C', 'phone': '+250 788 002 002', 'status': 'Available', 'collections': 0, 'rating': 4.5, 'lat': -1.9500, 'lng': 30.0700, 'todayEarned': 0, 'onTime': '92%'},
    {'name': 'David Nkurunziza', 'vehicle': 'RAF 789 D', 'phone': '+250 788 003 003', 'status': 'On Route', 'collections': 2, 'rating': 4.7, 'lat': -1.9550, 'lng': 30.0650, 'todayEarned': 30000, 'onTime': '98%'},
    {'name': 'Alice Mutesi', 'vehicle': 'RAG 012 E', 'phone': '+250 788 004 004', 'status': 'Offline', 'collections': 5, 'rating': 4.9, 'lat': -1.9380, 'lng': 30.0580, 'todayEarned': 75000, 'onTime': '99%'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _onRoute => _drivers.where((d) => d['status'] == 'On Route').length;
  int get _available => _drivers.where((d) => d['status'] == 'Available').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fleet Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.person_add_outlined), onPressed: () => _showAddDriverDialog(context)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [Tab(icon: Icon(Icons.people, size: 18), text: 'Drivers'), Tab(icon: Icon(Icons.map, size: 18), text: 'Live Map')],
        ),
      ),
      body: Column(children: [
        _buildStatsBanner(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildDriverList(), _buildDriverMap()],
          ),
        ),
      ]),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF0e7490)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _bannerStat('${_drivers.length}', 'Total Drivers', Icons.people),
        _bannerDivider(),
        _bannerStat('$_onRoute', 'On Route', Icons.directions_car),
        _bannerDivider(),
        _bannerStat('$_available', 'Available', Icons.check_circle),
        _bannerDivider(),
        _bannerStat('RWF 150K', "Today's Pay", Icons.payments),
      ]),
    );
  }

  Widget _bannerStat(String val, String label, IconData icon) => Column(children: [
    Row(children: [Icon(icon, color: Colors.white70, size: 14), const SizedBox(width: 4), Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
  ]);

  Widget _bannerDivider() => Container(width: 1, height: 30, color: Colors.white24);

  Widget _buildDriverList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drivers.length,
      itemBuilder: (_, i) => _buildDriverCard(_drivers[i]),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> d) {
    final status = d['status'] as String;
    final statusColor = status == 'On Route' ? Colors.green : status == 'Available' ? Colors.blue : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(d['name'].toString().split(' ').map((n) => n[0]).take(2).join(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(children: [
                const Icon(Icons.star, size: 13, color: Colors.amber),
                const SizedBox(width: 2),
                Text('${d['rating']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                const Icon(Icons.directions_car, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Text(d['vehicle'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _perfStat('${d['collections']}', 'Today'),
              _perfStat('RWF ${(d['todayEarned'] as int) ~/ 1000}K', 'Earned'),
              _perfStat(d['onTime'] as String, 'On-Time'),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _callDriver(d),
              icon: const Icon(Icons.phone, size: 14),
              label: const Text('Call', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 8)),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _showDriverPerformance(d),
              icon: const Icon(Icons.bar_chart, size: 14),
              label: const Text('Stats', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.textSecondary), foregroundColor: AppColors.textSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 8)),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: status == 'Available' ? () => _assignDriver(d) : null,
              icon: const Icon(Icons.assignment, size: 14, color: Colors.white),
              label: const Text('Assign', style: TextStyle(fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 8)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _perfStat(String val, String label) => Column(children: [
    Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);

  Widget _buildDriverMap() {
    return FlutterMap(
      options: const MapOptions(initialCenter: LatLng(-1.9441, 30.0619), initialZoom: 13),
      children: [
        TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'rw.ecotrade.mobile'),
        MarkerLayer(
          markers: _drivers.map((d) {
            final status = d['status'] as String;
            final color = status == 'On Route' ? Colors.green : status == 'Available' ? Colors.blue : Colors.grey;
            return Marker(
              point: LatLng(d['lat'] as double, d['lng'] as double),
              width: 50, height: 60,
              child: GestureDetector(
                onTap: () => _showDriverPerformance(d),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                    child: Text(d['name'].toString().split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  Icon(Icons.directions_car, color: color, size: 28),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _callDriver(Map<String, dynamic> d) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${d['name']} at ${d['phone']}...'), backgroundColor: AppColors.primary));
  }

  void _assignDriver(Map<String, dynamic> d) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${d['name']} assignment panel coming soon'), backgroundColor: Colors.blue));
  }

  void _showDriverPerformance(Map<String, dynamic> d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          Row(children: [
            CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(d['name'].toString().split(' ').map((n) => n[0]).take(2).join(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(d['vehicle'] as String, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 20),
          _perfRow('Phone', d['phone'] as String),
          _perfRow('Status', d['status'] as String),
          _perfRow('Rating', '${d['rating']} ⭐'),
          _perfRow('Today\'s Collections', '${d['collections']}'),
          _perfRow('Today\'s Earnings', 'RWF ${d['todayEarned']}'),
          _perfRow('On-Time Rate', d['onTime'] as String),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  Widget _perfRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );

  void _showAddDriverDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final vehicleCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const Text('Add New Driver', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Full Name', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          TextField(controller: vehicleCtrl, decoration: InputDecoration(labelText: 'Vehicle Plate', prefixIcon: const Icon(Icons.directions_car), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _drivers.add({'name': nameCtrl.text, 'vehicle': vehicleCtrl.text, 'phone': phoneCtrl.text, 'status': 'Available', 'collections': 0, 'rating': 0.0, 'lat': -1.9460, 'lng': 30.0640, 'todayEarned': 0, 'onTime': 'N/A'});
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${nameCtrl.text} added to fleet!'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Add Driver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ),
    );
  }
}
