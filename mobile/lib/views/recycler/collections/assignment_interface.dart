import 'package:flutter/material.dart';
class AssignmentInterface extends StatelessWidget {
  const AssignmentInterface({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Assign Driver'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 3, itemBuilder: (_, i) => Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.person, color: Colors.white)), title: Text('Driver ${i + 1}'), subtitle: const Text('Available'), trailing: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), child: const Text('Assign'))))));
  }
}
