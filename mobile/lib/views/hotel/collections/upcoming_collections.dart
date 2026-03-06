import 'package:flutter/material.dart';
class UpcomingCollections extends StatelessWidget {
  const UpcomingCollections({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 3, itemBuilder: (_, i) => Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.schedule, color: Colors.white, size: 18)), title: Text('Collection #${i + 1}'), subtitle: const Text('Tomorrow 09:00 AM'), trailing: const Chip(label: Text('Scheduled')))));
  }
}

