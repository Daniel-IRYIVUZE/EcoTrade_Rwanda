import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../theme/colors.dart';
import '../../shared/notifications_screen.dart';
import '../profile/recycler_profile_screen.dart';

class RecyclerHomeScreen extends StatefulWidget {
  final VoidCallback? onMarketplace;
  final VoidCallback? onBids;
  final VoidCallback? onFleet;

  const RecyclerHomeScreen({super.key, this.onMarketplace, this.onBids, this.onFleet});

  @override
  State<RecyclerHomeScreen> createState() => _RecyclerHomeScreenState();
}

class _RecyclerHomeScreenState extends State<RecyclerHomeScreen> {
  final _nearbyListings = [
    {'hotel': 'Marriott Hotel', 'type': 'UCO', 'volume': 120, 'price': 45000, 'distance': '1.2 km', 'lat': -1.9441, 'lng': 30.0619},
    {'hotel': 'Serena Hotel', 'type': 'Glass', 'volume': 80, 'price': 12000, 'distance': '2.1 km', 'lat': -1.9500, 'lng': 30.0700},
    {'hotel': 'Radisson Blu', 'type': 'Cardboard', 'volume': 200, 'price': 8000, 'distance': '3.4 km', 'lat': -1.9600, 'lng': 30.0800},
  ];

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
                _buildMetricsGrid(),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildMapSection(context),
                const SizedBox(height: 20),
                _buildNearbyListings(context),
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
      expandedHeight: 120,
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
                Text('Welcome back 👋', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                const Text('GreenEnergy Recyclers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              Row(children: [
                Stack(children: [
                  IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                  Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Text('5', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
                ]),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecyclerProfileScreen())),
                  child: const CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.business, color: Colors.white, size: 18)),
                ),
              ]),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {'label': 'Available Waste', 'value': '2.5 tons', 'icon': Icons.inventory, 'color': Colors.blue},
      {'label': 'Active Bids', 'value': '8', 'icon': Icons.gavel, 'color': Colors.orange},
      {'label': 'Fleet Active', 'value': '5/8', 'icon': Icons.directions_car, 'color': Colors.green},
      {'label': 'Completed', 'value': '124', 'icon': Icons.check_circle, 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.8),
      itemCount: metrics.length,
      itemBuilder: (_, i) {
        final m = metrics[i];
        final color = m['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(m['icon'] as IconData, color: color, size: 22)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(m['value'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(m['label'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _RQAction('Browse Waste', Icons.store, AppColors.primary, widget.onMarketplace),
      _RQAction('My Bids', Icons.gavel, const Color(0xFFD97706), widget.onBids),
      _RQAction('My Fleet', Icons.directions_car, const Color(0xFF2563EB), widget.onFleet),
      _RQAction('Analytics', Icons.bar_chart, const Color(0xFF7C3AED), () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analytics coming soon')))),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: actions.map((a) => Expanded(
        child: GestureDetector(
          onTap: a.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: a.color.withValues(alpha: 0.2)),
            ),
            child: Column(children: [
              Icon(a.icon, color: a.color, size: 26),
              const SizedBox(height: 6),
              Text(a.label, style: TextStyle(color: a.color, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ]),
          ),
        ),
      )).toList()),
    ]);
  }

  Widget _buildMapSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Nearby Waste Sources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(onPressed: widget.onMarketplace, child: const Text('View All', style: TextStyle(color: AppColors.secondary, fontSize: 13))),
      ]),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 200,
          child: FlutterMap(
            options: const MapOptions(initialCenter: LatLng(-1.9441, 30.0619), initialZoom: 13),
            children: [
              TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'rw.ecotrade.mobile'),
              MarkerLayer(
                markers: _nearbyListings.map((l) => Marker(
                  point: LatLng(l['lat'] as double, l['lng'] as double),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showListingQuickBid(context, l),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildNearbyListings(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Available Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ..._nearbyListings.map((l) => Container(
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
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.eco, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l['hotel'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${l['type']} • ${l['volume']} kg • ${l['distance']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('RWF ${l['price']}', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showListingQuickBid(context, l),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Bid', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ]),
      )),
    ]);
  }

  void _showListingQuickBid(BuildContext context, Map<String, dynamic> listing) {
    final ctrl = TextEditingController(text: '${listing['price']}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Text('${listing['hotel']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${listing['type']} • ${listing['volume']} kg', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Your Bid (RWF)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bid of RWF ${ctrl.text} placed!'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Place Bid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ),
    );
  }
}

class _RQAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  _RQAction(this.label, this.icon, this.color, this.onTap);
}
