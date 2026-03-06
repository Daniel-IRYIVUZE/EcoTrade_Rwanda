import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../shared/notifications_screen.dart';
import '../navigation/navigation_screen.dart';
import '../collection/collection_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final VoidCallback? onNavigate;
  final VoidCallback? onEarnings;
  final VoidCallback? onHistory;
  const DriverHomeScreen({super.key, this.onNavigate, this.onEarnings, this.onHistory});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _routeStarted = false;
  int _completedStops = 0;

  final List<Map<String, dynamic>> _stops = [
    {'id': '1', 'hotel': 'Marriott Hotel', 'address': 'KG 7 Ave, Kigali', 'waste': 'UCO', 'volume': 120, 'status': 'pending', 'time': '09:00 AM', 'lat': -1.9441, 'lng': 30.0619},
    {'id': '2', 'hotel': 'Serena Hotel', 'address': 'KG 2 Ave, Kigali', 'waste': 'Glass', 'volume': 85, 'status': 'pending', 'time': '10:30 AM', 'lat': -1.9500, 'lng': 30.0700},
    {'id': '3', 'hotel': 'Radisson Blu', 'address': 'KG 1 St, Kigali', 'waste': 'Cardboard', 'volume': 200, 'status': 'pending', 'time': '12:00 PM', 'lat': -1.9600, 'lng': 30.0800},
  ];

  double get _progress => _stops.isEmpty ? 0 : _completedStops / _stops.length;
  Map<String, dynamic>? get _nextStop => _stops.firstWhere((s) => s['status'] == 'pending', orElse: () => _stops.last);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRouteCard(context),
                const SizedBox(height: 20),
                _buildEarningsRow(),
                const SizedBox(height: 20),
                const Text('Collection Stops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._stops.asMap().entries.map((e) => _buildStopCard(context, e.key, e.value)),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF0e7490)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('Today\'s Route', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                const Text('Jean Pierre', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
              Row(children: [
                _notifBtn(context),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: _routeStarted ? Colors.green.withValues(alpha: 0.3) : Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: Text(_routeStarted ? '🟢 Active' : '⚪ Offline', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _notifBtn(BuildContext context) => Stack(children: [
    IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
    Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
  ]);

  Widget _buildRouteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Route Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: (_routeStarted ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(_routeStarted ? 'In Progress' : 'Not Started', style: TextStyle(color: _routeStarted ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _routeStat('${_stops.length}', 'Stops', Icons.location_on),
          _routeStat('${(_stops.fold<int>(0, (s, e) => s + (e['volume'] as int)))} kg', 'Total', Icons.scale),
          _routeStat('${(_progress * 100).toInt()}%', 'Done', Icons.check_circle),
          _routeStat('~42 km', 'Distance', Icons.route),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary), minHeight: 8),
        ),
        if (!_routeStarted) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () { setState(() => _routeStarted = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Route started! Drive safe 🚗'), backgroundColor: Colors.green)); },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start Route'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverNavigationScreen())),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('View Map'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
            )),
          ]),
        ] else ...[
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverNavigationScreen())),
            icon: const Icon(Icons.navigation, size: 18),
            label: Text('Navigate to ${_nextStop?['hotel'] ?? 'Next Stop'}'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ]),
    );
  }

  Widget _routeStat(String value, String label, IconData icon) => Column(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);

  Widget _buildEarningsRow() {
    return Row(children: [
      _earningsCard('25,000', 'Today\'s Earnings', Icons.attach_money, Colors.green, widget.onEarnings),
      const SizedBox(width: 12),
      _earningsCard('142,000', 'This Week', Icons.trending_up, Colors.blue, widget.onEarnings),
    ]);
  }

  Widget _earningsCard(String amount, String label, IconData icon, Color color, VoidCallback? onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RWF $amount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ]),
      ),
    ),
  );

  Widget _buildStopCard(BuildContext context, int index, Map<String, dynamic> stop) {
    final isCompleted = stop['status'] == 'completed';
    final isCurrent = !isCompleted && _stops.indexWhere((s) => s['status'] == 'pending') == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent ? Border.all(color: AppColors.secondary, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : isCurrent ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.15),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text('${index + 1}', style: TextStyle(color: isCompleted ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(stop['hotel'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(stop['address'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${stop['waste']} • ${stop['volume']} kg • ${stop['time']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 22)
            : _routeStarted && isCurrent
                ? ElevatedButton(
                    onPressed: () => _handleArrival(context, index, stop),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Collect', style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                : Text(stop['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ),
    );
  }

  void _handleArrival(BuildContext context, int index, Map<String, dynamic> stop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Arrival'),
        content: Text('Arrived at ${stop['hotel']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverCollectionScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Yes, Collect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
