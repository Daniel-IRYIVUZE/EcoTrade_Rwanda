import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../auth/login_screen.dart';

class HotelProfileScreen extends StatelessWidget {
  const HotelProfileScreen({super.key});

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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.hotel, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 12),
                  const Text('Mille Collines Hotel', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Kigali, Rwanda', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreenScoreCard(),
                const SizedBox(height: 16),
                _buildSection('Business Info', [
                  _tile(Icons.business, 'Business Name', 'Mille Collines Hotel'),
                  _tile(Icons.location_on, 'Address', 'KG 7 Ave, Kigali City Centre'),
                  _tile(Icons.phone, 'Phone', '+250 780 162 164'),
                  _tile(Icons.email, 'Email', 'hotel@millecollines.rw'),
                  _tile(Icons.language, 'Type', 'Hotel & Hospitality'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Documents', [
                  _docTile(context, 'Business License', true),
                  _docTile(context, 'Environmental Permit', true),
                  _docTile(context, 'Tax Certificate', false),
                ]),
                const SizedBox(height: 16),
                _buildSection('Account', [
                  _actionTile(context, Icons.notifications_outlined, 'Notification Settings', () {}),
                  _actionTile(context, Icons.lock_outline, 'Change Password', () {}),
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

  Widget _buildGreenScoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Green Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Text('850 pts', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: const Text('Top 10% in Kigali', style: TextStyle(color: Colors.white, fontSize: 11))),
        ])),
        const SizedBox(
          width: 70,
          height: 70,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: 0.85, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 7),
            Text('85%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
        child: Column(children: children)),
    ]);
  }

  Widget _tile(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
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
