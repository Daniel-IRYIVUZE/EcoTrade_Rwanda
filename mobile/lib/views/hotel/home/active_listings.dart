import 'package:flutter/material.dart';
export 'active_listings_widget.dart';

class ActiveListingsScreen extends StatelessWidget {
  const ActiveListingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Active Listings'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 5, itemBuilder: (_, i) => Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.recycling, color: Colors.white, size: 18)), title: Text('Listing #${i + 1}'), subtitle: const Text('120 kg UCO - Active'), trailing: const Chip(label: Text('Active'))))));
  }
}

