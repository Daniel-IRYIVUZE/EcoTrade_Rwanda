import 'package:flutter/material.dart';
import '../hotel/home/hotel_home_screen.dart';
import '../hotel/listings/list_waste_screen.dart';
import '../hotel/bids/bids_screen.dart';
import '../hotel/collections/collections_screen.dart';
import '../hotel/profile/hotel_profile_screen.dart';

class HotelDashboard extends StatefulWidget {
  const HotelDashboard({super.key});
  @override
  State<HotelDashboard> createState() => _HotelDashboardState();
}

class _HotelDashboardState extends State<HotelDashboard> {
  int _selectedIndex = 0;

  void _switchTab(int index) => setState(() => _selectedIndex = index);

  List<Widget> get _screens => [
    HotelHomeScreen(
      onListWaste: () => _switchTab(1),
      onViewBids: () => _switchTab(2),
      onViewCollections: () => _switchTab(3),
    ),
    const ListWasteScreen(),
    const HotelBidsScreen(),
    const HotelCollectionsScreen(),
    const HotelProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _switchTab,
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black12,
        indicatorColor: const Color(0xFF0F4C3A).withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF0F4C3A)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, color: Color(0xFF0F4C3A)), label: 'List'),
          NavigationDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel, color: Color(0xFF0F4C3A)), label: 'Bids'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping, color: Color(0xFF0F4C3A)), label: 'Pickups'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF0F4C3A)), label: 'Profile'),
        ],
      ),
    );
  }
}
