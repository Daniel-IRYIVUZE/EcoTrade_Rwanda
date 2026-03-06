import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {'title': 'New bid received', 'body': 'Kigali Recyclers placed a bid of RWF 45,000 on your UCO listing', 'time': '5m ago', 'icon': Icons.gavel, 'color': Colors.blue},
    {'title': 'Collection confirmed', 'body': 'Your collection for today at 09:00 AM has been confirmed', 'time': '1h ago', 'icon': Icons.local_shipping, 'color': Colors.green},
    {'title': 'Green Score update', 'body': 'Your green score increased to 750 points!', 'time': '3h ago', 'icon': Icons.eco, 'color': Colors.teal},
    {'title': 'Payment received', 'body': 'You received RWF 45,000 for your glass collection', 'time': '1d ago', 'icon': Icons.payment, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = _notifications[i];
          return ListTile(
            leading: CircleAvatar(backgroundColor: (n['color'] as Color).withValues(alpha: 0.1), child: Icon(n['icon'] as IconData, color: n['color'] as Color)),
            title: Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(n['body'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(n['time'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          );
        },
      ),
    );
  }
}
