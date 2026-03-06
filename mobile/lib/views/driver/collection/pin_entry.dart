import 'package:flutter/material.dart';

class PinEntryWidget extends StatefulWidget {
  final Function(String) onPinSubmitted;
  const PinEntryWidget({super.key, required this.onPinSubmitted});
  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Enter Hotel PIN to confirm collection', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        obscureText: true,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
        decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF3F4F6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), hintText: '------'),
      ),
      ElevatedButton(
        onPressed: () => widget.onPinSubmitted(_ctrl.text),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
        child: const Text('Confirm'),
      ),
    ]);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}


