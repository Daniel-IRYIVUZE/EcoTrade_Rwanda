import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/green_score_card.dart';
import '../../../theme/colors.dart';
import '../../shared/notifications_screen.dart';
import '../profile/hotel_profile_screen.dart';

class HotelHomeScreen extends StatelessWidget {
  final VoidCallback? onListWaste;
  final VoidCallback? onViewBids;
  final VoidCallback? onViewCollections;

  const HotelHomeScreen({
    super.key,
    this.onListWaste,
    this.onViewBids,
    this.onViewCollections,
  });

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
                const GreenScoreCard(score: 85),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildSectionHeader('Active Listings', 'See all', context),
                const SizedBox(height: 12),
                _buildActiveListings(context),
                const SizedBox(height: 20),
                _buildSectionHeader('Recent Bids', 'View all', context, onSeeAll: onViewBids),
                const SizedBox(height: 12),
                _buildRecentBids(context),
                const SizedBox(height: 20),
                _buildRevenueSummary(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onListWaste,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('List Waste', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF064e3b), Color(0xFF0e7490)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning! 👋', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                          const Text('Mille Collines Hotel', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          _notifButton(context),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelProfileScreen())),
                            child: const CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 20)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('45K RWF', 'Revenue', Icons.trending_up, Colors.green),
        const SizedBox(width: 10),
        _statCard('3', 'Listings', Icons.inventory_2, Colors.blue),
        const SizedBox(width: 10),
        _statCard('7', 'Pickups', Icons.local_shipping, Colors.orange),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QAction('New Listing', Icons.add_circle_outline, AppColors.primary, onListWaste),
      _QAction('My Bids', Icons.gavel, const Color(0xFF2563EB), onViewBids),
      _QAction('Collections', Icons.local_shipping, const Color(0xFFD97706), onViewCollections),
      _QAction('Reports', Icons.bar_chart, const Color(0xFF7C3AED), () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reports coming soon!')))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) => Expanded(
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
                child: Column(
                  children: [
                    Icon(a.icon, color: a.color, size: 26),
                    const SizedBox(height: 6),
                    Text(a.label, style: TextStyle(color: a.color, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action, BuildContext context, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: Text(action, style: const TextStyle(color: AppColors.secondary, fontSize: 13))),
      ],
    );
  }

  Widget _buildActiveListings(BuildContext context) {
    final types = ['UCO', 'Glass', 'Cardboard'];
    final volumes = ['120 kg', '80 kg', '200 kg'];
    final bids = [3, 1, 5];
    final times = ['2h left', '1d left', '3d left'];
    final colors = [AppColors.uco, AppColors.glass, AppColors.cardboard];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _showListingDetail(context, types[i], volumes[i], bids[i]),
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: colors[i].withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.eco, size: 16, color: colors[i]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                      child: Text('Active', style: TextStyle(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(types[i], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(volumes[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${bids[i]} bids', style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(times[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBids(BuildContext context) {
    final bids = [
      {'recycler': 'GreenEnergy Recyclers', 'type': 'UCO', 'amount': 'RWF 45,000', 'status': 'Pending'},
      {'recycler': 'Kigali EcoPlant', 'type': 'Glass', 'amount': 'RWF 12,000', 'status': 'Accepted'},
    ];

    return Column(
      children: bids.map((bid) {
        final isPending = bid['status'] == 'Pending';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.gavel, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bid['recycler']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${bid['type']} • ${bid['amount']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (isPending) ...[
                GestureDetector(
                  onTap: () => _confirmBidAction(context, 'Accept', bid['recycler']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _confirmBidAction(context, 'Reject', bid['recycler']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(border: Border.all(color: Colors.red.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Text('Reject', style: TextStyle(color: Colors.red.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('Accepted', style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRevenueSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Revenue Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text('+15% this month', style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('125,000 RWF total', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4.5), FlSpot(5, 6), FlSpot(6, 5.5)],
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.secondary.withValues(alpha: 0.08)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showListingDetail(BuildContext context, String type, String volume, int bidCount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Text(type, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Volume: $volume • $bidCount bids received', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); if (onViewBids != null) onViewBids!(); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('View Bids', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBidAction(BuildContext context, String action, String recycler) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$action Bid'),
        content: Text('$action the bid from $recycler?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Bid ${action.toLowerCase()}ed!'),
                backgroundColor: action == 'Accept' ? Colors.green : Colors.red,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: action == 'Accept' ? AppColors.primary : Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _QAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  _QAction(this.label, this.icon, this.color, this.onTap);
}
