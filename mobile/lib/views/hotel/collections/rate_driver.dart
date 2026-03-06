import 'package:flutter/material.dart';
class RateDriverScreen extends StatefulWidget {
  const RateDriverScreen({super.key});
  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}
class _RateDriverScreenState extends State<RateDriverScreen> {
  int _rating = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Driver'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const CircleAvatar(radius: 40, backgroundColor: Color(0xFF0F4C3A), child: Icon(Icons.person, size: 40, color: Colors.white)),
        const SizedBox(height: 16),
        const Text('How was your collection?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36), onPressed: () => setState(() => _rating = i + 1)))),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _rating > 0 ? () => Navigator.pop(context) : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)), child: const Text('Submit Rating')),
      ])),
    );
  }
}

