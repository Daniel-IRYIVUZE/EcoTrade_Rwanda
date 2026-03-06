import 'package:flutter/material.dart';

class WeighingInterface extends StatefulWidget {
  final Function(double) onWeightConfirmed;
  const WeighingInterface({super.key, required this.onWeightConfirmed});
  @override
  State<WeighingInterface> createState() => _WeighingInterfaceState();
}
class _WeighingInterfaceState extends State<WeighingInterface> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Icon(Icons.scale, size: 48, color: Color(0xFF0F4C3A)),
          const SizedBox(height: 8),
          const Text('Enter Actual Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(hintText: '0.0 kg', suffixText: 'kg', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: const Color(0xFFF3F4F6))),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () { final v = double.tryParse(_ctrl.text); if (v != null) widget.onWeightConfirmed(v); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
            child: const Text('Confirm Weight'),
          ),
        ]),
      ),
    );
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}


