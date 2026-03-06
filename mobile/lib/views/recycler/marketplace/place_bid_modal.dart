import 'package:flutter/material.dart';
class PlaceBidModal extends StatefulWidget {
  final Map<String, dynamic> listing;
  const PlaceBidModal({super.key, required this.listing});
  @override
  State<PlaceBidModal> createState() => _PlaceBidModalState();
}
class _PlaceBidModalState extends State<PlaceBidModal> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Bid on ${widget.listing['hotel'] ?? 'Hotel'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextField(controller: _ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Your Bid (RWF)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixText: 'RWF ')),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)), child: const Text('Submit Bid')),
      const SizedBox(height: 24),
    ]));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}
