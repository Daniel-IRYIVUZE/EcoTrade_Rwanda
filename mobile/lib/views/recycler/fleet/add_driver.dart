import 'package:flutter/material.dart';
class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});
  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}
class _AddDriverScreenState extends State<AddDriverScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _plate = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Add Driver'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: _name, decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: const Color(0xFFF3F4F6))),
      const SizedBox(height: 12),
      TextField(controller: _phone, decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: const Color(0xFFF3F4F6))),
      const SizedBox(height: 12),
      TextField(controller: _plate, decoration: InputDecoration(labelText: 'Vehicle Plate', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: const Color(0xFFF3F4F6))),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)), child: const Text('Add Driver')),
    ]));
  }
  @override
  void dispose() { _name.dispose(); _phone.dispose(); _plate.dispose(); super.dispose(); }
}
