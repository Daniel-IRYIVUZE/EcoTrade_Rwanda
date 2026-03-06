import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Ecotrade'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: const Color(0xFF0F4C3A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.eco, size: 56, color: Color(0xFF0F4C3A)),
          )),
          const SizedBox(height: 24),
          const Text('Ecotrade Platform', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Version 1.0.0', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          const Text('Our Mission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Connecting Kigali\'s HORECA sector with recyclers to create a circular economy that transforms waste into value. We leverage technology to reduce logistics costs, minimize environmental impact, and generate sustainable revenue for all stakeholders.', style: TextStyle(height: 1.6)),
          const SizedBox(height: 24),
          const Text('Key Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...[
            ('Offline-First', 'Works without internet, syncs when connected', Icons.wifi_off),
            ('Live Tracking', 'Real-time GPS tracking of collections', Icons.location_on),
            ('Instant Payments', 'Fast, secure mobile money payments', Icons.payments),
            ('Green Scores', 'Gamified sustainability metrics', Icons.eco),
          ].map((f) => ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFF0F4C3A).withValues(alpha: 0.1), child: Icon(f.$3, color: const Color(0xFF0F4C3A))),
            title: Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(f.$2),
          )),
          const SizedBox(height: 24),
          const Center(child: Text('© 2026 Ecotrade Rwanda Ltd.', style: TextStyle(color: Color(0xFF9CA3AF)))),
        ]),
      ),
    );
  }
}
