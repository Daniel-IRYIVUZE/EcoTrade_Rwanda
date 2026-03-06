import 'package:flutter/material.dart';
import '../driver/earnings/earnings_screen.dart';
import '../driver/history/history_screen.dart';
import '../driver/home/driver_home_screen.dart';
import '../driver/navigation/navigation_screen.dart';
import '../driver/profile/driver_profile_screen.dart';
import '../../widgets/offline_indicator.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});
  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;

  void _switchTab(int index) => setState(() => _selectedIndex = index);

  List<Widget> get _screens => [
    DriverHomeScreen(
      onNavigate: () => _switchTab(1),
      onEarnings: () => _switchTab(2),
      onHistory: () => _switchTab(3),
    ),
    const DriverNavigationScreen(),
    const DriverEarningsScreen(),
    const DriverHistoryScreen(),
    const DriverProfileScreen(),
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
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: Color(0xFF0F4C3A)), label: 'Navigate'),
          NavigationDestination(icon: Icon(Icons.attach_money_outlined), selectedIcon: Icon(Icons.attach_money, color: Color(0xFF0F4C3A)), label: 'Earnings'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: Color(0xFF0F4C3A)), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF0F4C3A)), label: 'Profile'),
        ],
      ),
    );
  }
}
