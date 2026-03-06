import 'package:flutter/material.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ...[('Driving License', 'Expires: Dec 2026', true), ('Vehicle Registration', 'Expires: Jun 2025', true), ('Insurance', 'Pending renewal', false)].map((doc) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.description, color: doc.$3 ? Colors.green : Colors.orange),
            title: Text(doc.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(doc.$2),
            trailing: doc.$3 ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.warning, color: Colors.orange),
          ),
        )),
      ]),
    );
  }
}


