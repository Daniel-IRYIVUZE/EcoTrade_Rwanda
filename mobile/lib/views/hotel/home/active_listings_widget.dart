import 'package:flutter/material.dart';
class ActiveListingsWidget extends StatelessWidget {
  const ActiveListingsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...[('UCO', '120 kg', '#0F4C3A'), ('Glass', '85 kg', '#10B981'), ('Cardboard', '200 kg', '#059669')].map((l) => Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: ListTile(leading: CircleAvatar(backgroundColor: Color(int.parse('0xFF${l.$3.substring(1)}')).withValues(alpha: 0.1), child: Icon(Icons.recycling, color: Color(int.parse('0xFF${l.$3.substring(1)}')))), title: Text(l.$1), subtitle: Text(l.$2), trailing: const Chip(label: Text('Active'), padding: EdgeInsets.zero)))),
    ]);
  }
}

