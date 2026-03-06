import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How can we help?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Contact our support team 24/7', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          ...[
            ('Call Us', '+250 788 000 000', Icons.phone, () {}),
            ('Email Us', 'support@ecotrade.rw', Icons.email, () {}),
            ('WhatsApp', '+250 788 000 001', Icons.chat, () {}),
          ].map((c) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF0F4C3A), child: Icon(c.$3, color: Colors.white, size: 18)),
              title: Text(c.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(c.$2),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: c.$4,
            ),
          )),
          const SizedBox(height: 24),
          const Text('FAQs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...[
            ('How do I list waste?', 'Tap the + button on the home screen, fill in waste type, volume, and pickup time.'),
            ('How long until my bid is accepted?', 'Bids are typically reviewed within 24 hours. You\'ll receive a notification when accepted.'),
            ('How do I receive payment?', 'Payments are processed via mobile money (MTN/Airtel) within 24h of collection confirmation.'),
            ('What if a driver doesn\'t arrive?', 'Contact support immediately. We will reassign and compensate for any inconvenience.'),
          ].map((faq) => ExpansionTile(
            title: Text(faq.$1, style: const TextStyle(fontWeight: FontWeight.w500)),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(faq.$2, style: const TextStyle(color: Color(0xFF6B7280))))],
          )),
        ]),
      ),
    );
  }
}
