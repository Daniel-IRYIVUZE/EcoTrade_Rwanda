import 'package:flutter/material.dart';
import '../recycler/home/recycler_home_screen.dart';
import '../recycler/marketplace/marketplace_screen.dart';
import '../recycler/bids/my_bids_screen.dart';
import '../recycler/fleet/fleet_screen.dart';
import '../recycler/profile/recycler_profile_screen.dart';
import '../../widgets/offline_indicator.dart';

class RecyclerDashboard extends StatefulWidget {
  const RecyclerDashboard({super.key});
  @override
  State<RecyclerDashboard> createState() => _RecyclerDashboardState();
}

class _RecyclerDashboardState extends State<RecyclerDashboard> {
  int _selectedIndex = 0;

  void _switchTab(int index) => setState(() => _selectedIndex = index);

  List<Widget> get _screens => [
    RecyclerHomeScreen(
      onMarketplace: () => _switchTab(1),
      onBids: () => _switchTab(2),
      onFleet: () => _switchTab(3),
    ),
    const MarketplaceScreen(),
    const RecyclerBidsScreen(),
    const FleetScreen(),
    const RecyclerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          const OfflineIndicator(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _switchTab,
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black12,
        indicatorColor: const Color(0xFF0F4C3A).withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF0F4C3A)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store, color: Color(0xFF0F4C3A)), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel, color: Color(0xFF0F4C3A)), label: 'My Bids'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping, color: Color(0xFF0F4C3A)), label: 'Fleet'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF0F4C3A)), label: 'Profile'),
        ],
      ),
    );
  }
}
