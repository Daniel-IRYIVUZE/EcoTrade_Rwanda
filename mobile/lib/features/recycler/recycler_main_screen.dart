import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../shared/widgets/shared_cards.dart';
import '../shared/widgets/offline_banner.dart';
import 'marketplace_screen.dart';
import 'my_bids_screen.dart';
import 'fleet_screen.dart';
import 'recycler_collections_screen.dart';

class RecyclerMainScreen extends ConsumerStatefulWidget {
  final Widget child;
  const RecyclerMainScreen({super.key, required this.child});

  @override
  ConsumerState<RecyclerMainScreen> createState() => _RecyclerMainScreenState();
}

class _RecyclerMainScreenState extends ConsumerState<RecyclerMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _RecyclerHomeTab(),
      const MarketplaceScreen(),
      const MyBidsScreen(),
      const FleetScreen(),
      const RecyclerCollectionsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          backgroundColor: AppColors.surface,
          elevation: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Market'),
            NavigationDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: 'My Bids'),
            NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Fleet'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Jobs'),
          ],
        ),
      ),
    );
  }
}

// ─── Recycler Home Tab ────────────────────────────────────────────────────────
class _RecyclerHomeTab extends ConsumerWidget {
  const _RecyclerHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(openListingsProvider);
    final stats = ref.watch(recyclerStatsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            floating: true,
            expandedHeight: 70,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _greeting(),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
                      ),
                      const Text(
                        'GreenRecycle Ltd',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFD1FAE5),
                    child: Text('GR', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const OfflineBanner(),
                const SizedBox(height: 12),

                // Stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(
                      title: 'Open Listings',
                      value: '${listings.length}',
                      subtitle: 'in marketplace',
                      icon: Icons.inventory_rounded,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Active Bids',
                      value: '${stats['activeBids'] ?? 0}',
                      subtitle: 'awaiting response',
                      icon: Icons.gavel_outlined,
                      iconColor: AppColors.accent,
                      iconBg: AppColors.accentLight,
                    ),
                    StatCard(
                      title: 'Won Bids',
                      value: '${stats['wonBids'] ?? 0}',
                      subtitle: 'collections',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.info,
                      iconBg: const Color(0xFFDBEAFE),
                    ),
                    StatCard(
                      title: 'Revenue',
                      value: 'RWF ${_fmtK(stats['totalEarnings'] ?? 0)}',
                      subtitle: 'total earnings',
                      icon: Icons.trending_up,
                      iconColor: AppColors.primaryDark,
                    ),
                  ],
                ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),

                const SizedBox(height: 24),

                // Quick Bid
                _QuickBidCard().animate().slideY(begin: 0.2, duration: 400.ms, delay: 100.ms).fadeIn(),

                const SizedBox(height: 24),

                // Map Preview
                const SectionHeader(title: 'Nearby Listings', actionLabel: 'See Map'),
                const SizedBox(height: 12),

                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: const _MapPlaceholder(),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  '12 listings within 5km of Kigali City',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View All'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 200.ms).fadeIn(),

                const SizedBox(height: 24),

                // Recent activity — latest open listings
                const SectionHeader(title: 'Recent Activity'),
                const SizedBox(height: 12),

                ...listings.take(3).map((listing) => _ActivityCard(
                  icon: Icons.business_outlined,
                  title: 'New listing from ${listing.businessName}',
                  subtitle: '${listing.wasteType.label} ${listing.volume.toStringAsFixed(0)}${listing.unit} • ${listing.activeBidCount} bids',
                  color: AppColors.primary,
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _fmtK(dynamic val) {
    final n = (val ?? 0).toDouble();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }
}

class _QuickBidCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ Quick Bid',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'New listings available\nin your area',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7C3AED),
                    minimumSize: const Size(120, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Browse Now', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Text('🏭', style: TextStyle(fontSize: 56)),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD4EDDA),
      child: Stack(
        children: [
          // Grid lines (road simulation)
          ...List.generate(5, (i) => Positioned(
            left: i * 60.0,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.white.withOpacity(0.5)),
          )),
          ...List.generate(5, (i) => Positioned(
            top: i * 40.0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.white.withOpacity(0.5)),
          )),
          // Map pins
          ...[
            {'x': 0.3, 'y': 0.4},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.5, 'y': 0.6},
          ].map((pos) => Positioned(
            left: MediaQuery.of(context).size.width * (pos['x']!),
            top: 190 * (pos['y']!),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.recycling, color: Colors.white, size: 14),
            ),
          )),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 300.ms).fadeIn();
  }
}
