import 'package:flutter/material.dart';
class VolumeInput extends StatefulWidget {
  final Function(double) onChanged;
  const VolumeInput({super.key, required this.onChanged});
  @override
  State<VolumeInput> createState() => _VolumeInputState();
}
class _VolumeInputState extends State<VolumeInput> {
  final _ctrl = TextEditingController();
  String _unit = 'kg';
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: TextField(controller: _ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) { final d = double.tryParse(v) ?? 0; widget.onChanged(_unit == 'kg' ? d : d * 1000); }, decoration: InputDecoration(labelText: 'Volume', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: const Color(0xFFF3F4F6)))),
      const SizedBox(width: 12),
      DropdownButton<String>(value: _unit, items: ['kg', 'tons'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (v) => setState(() => _unit = v!)),
    ]);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

