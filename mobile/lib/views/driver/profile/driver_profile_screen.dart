import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import '../../../theme/colors.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF0e7490)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Stack(alignment: Alignment.bottomRight, children: [
                    const CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 44)),
                    Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.circle, color: Colors.white, size: 10)),
                  ]),
                  const SizedBox(height: 10),
                  const Text('Jean Pierre', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Driver • Active', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildSection('Personal Info', [
                  _tile(Icons.person, 'Full Name', 'Jean Pierre Habimana'),
                  _tile(Icons.phone, 'Phone', '+250 780 000 001'),
                  _tile(Icons.email, 'Email', 'driver@ecotrade.rw'),
                  _tile(Icons.location_on, 'Base Location', 'Kicukiro, Kigali'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Vehicle Info', [
                  _tile(Icons.directions_car, 'Vehicle', 'Toyota Hilux'),
                  _tile(Icons.confirmation_number, 'Plate Number', 'RAD 123 B'),
                  _tile(Icons.local_shipping, 'Capacity', '500 kg'),
                  _tileVerified('Vehicle License', true),
                  _tileVerified('Insurance', true),
                ]),
                const SizedBox(height: 16),
                _buildSection('Ratings & Performance', [
                  _rating(),
                  _tile(Icons.check_circle, 'Completed Jobs', '124 jobs'),
                  _tile(Icons.route, 'Total Distance', '1,248 km'),
                  _tile(Icons.eco, 'Waste Collected', '2.1 tons'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Settings', [
                  _actionTile(context, Icons.notifications_outlined, 'Notifications', () {}),
                  _actionTile(context, Icons.lock_outline, 'Change Password', () {}),
                  _actionTile(context, Icons.help_outline, 'Help & Support', () {}),
                ]),
                const SizedBox(height: 16),
                _logoutBtn(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _statCard('4.8', 'Rating', Icons.star, Colors.amber),
      const SizedBox(width: 10),
      _statCard('124', 'Jobs', Icons.work, Colors.blue),
      const SizedBox(width: 10),
      _statCard('95%', 'On-Time', Icons.access_time, Colors.green),
    ]);
  }

  Widget _statCard(String val, String label, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _buildSection(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]), child: Column(children: children)),
  ]);

  Widget _tile(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    dense: true,
  );

  Widget _tileVerified(String label, bool verified) => ListTile(
    leading: Icon(verified ? Icons.verified : Icons.error_outline, color: verified ? Colors.green : Colors.orange, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 13)),
    trailing: Text(verified ? 'Valid' : 'Upload', style: TextStyle(color: verified ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
    dense: true,
  );

  Widget _rating() => ListTile(
    leading: const Icon(Icons.star, color: Colors.amber, size: 20),
    title: const Text('Driver Rating', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    subtitle: Row(children: List.generate(5, (i) => Icon(i < 5 ? Icons.star : Icons.star_outline, size: 16, color: Colors.amber))),
    trailing: const Text('4.8/5.0', style: TextStyle(fontWeight: FontWeight.bold)),
    dense: true,
  );

  Widget _actionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 13)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
    onTap: onTap,
    dense: true,
  );

  Widget _logoutBtn(BuildContext context) => ElevatedButton.icon(
    onPressed: () => showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
    icon: const Icon(Icons.logout, color: Colors.white),
    label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
  );
}
