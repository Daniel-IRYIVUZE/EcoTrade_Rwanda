import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../auth/login_screen.dart';

class RecyclerProfileScreen extends StatelessWidget {
  const RecyclerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF0e7490)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.recycling, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 12),
                  const Text('GreenEnergy Recyclers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Kigali, Rwanda', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Gold Partner', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
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
                _buildSection('Company Info', [
                  _tile(Icons.business, 'Company Name', 'GreenEnergy Recyclers Ltd'),
                  _tile(Icons.location_on, 'Address', 'KG 15 Ave, Kicukiro, Kigali'),
                  _tile(Icons.phone, 'Phone', '+250 788 123 456'),
                  _tile(Icons.email, 'Email', 'info@greenenergy.rw'),
                  _tile(Icons.recycling, 'Specialization', 'UCO, Glass, Cardboard, Plastics'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Waste Types Handled', [
                  _wasteTypeTile('Used Cooking Oil (UCO)', Icons.opacity, const Color(0xFFD97706)),
                  _wasteTypeTile('Glass & Bottles', Icons.wine_bar, const Color(0xFF2563EB)),
                  _wasteTypeTile('Cardboard & Paper', Icons.inventory_2, const Color(0xFF7C3AED)),
                  _wasteTypeTile('Plastics', Icons.local_drink, const Color(0xFF059669)),
                ]),
                const SizedBox(height: 16),
                _buildSection('Documents', [
                  _docTile(context, 'Business License', true),
                  _docTile(context, 'Environmental Permit', true),
                  _docTile(context, 'Waste Handler Certification', true),
                  _docTile(context, 'Tax Certificate', false),
                ]),
                const SizedBox(height: 16),
                _buildSection('Account', [
                  _actionTile(context, Icons.notifications_outlined, 'Notification Settings', () {}),
                  _actionTile(context, Icons.lock_outline, 'Change Password', () {}),
                  _actionTile(context, Icons.payments_outlined, 'Payment Methods', () {}),
                  _actionTile(context, Icons.help_outline, 'Help & Support', () {}),
                  _actionTile(context, Icons.info_outline, 'About EcoTrade', () {}),
                ]),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _stat('124', 'Collections'),
        _divider(),
        _stat('4.8', 'Rating'),
        _divider(),
        _stat('2.1T', 'Recycled'),
        _divider(),
        _stat('98%', 'On Time'),
      ]),
    );
  }

  Widget _stat(String val, String label) => Column(children: [
    Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);

  Widget _divider() => Container(width: 1, height: 36, color: Colors.grey.shade200);

  Widget _buildSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
        child: Column(children: children),
      ),
    ]);
  }

  Widget _tile(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    dense: true,
  );

  Widget _wasteTypeTile(String name, IconData icon, Color color) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 18),
    ),
    title: Text(name, style: const TextStyle(fontSize: 13)),
    trailing: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
    ),
    dense: true,
  );

  Widget _docTile(BuildContext context, String name, bool verified) => ListTile(
    leading: Icon(verified ? Icons.verified : Icons.upload_file, color: verified ? Colors.green : Colors.orange, size: 20),
    title: Text(name, style: const TextStyle(fontSize: 13)),
    trailing: Text(verified ? 'Verified' : 'Upload', style: TextStyle(color: verified ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
    onTap: verified ? null : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload feature coming soon'))),
    dense: true,
  );

  Widget _actionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 13)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
    onTap: onTap,
    dense: true,
  );

  Widget _buildLogoutButton(BuildContext context) => ElevatedButton.icon(
    onPressed: () => showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
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
