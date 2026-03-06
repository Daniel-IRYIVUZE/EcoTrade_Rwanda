import 'package:flutter/material.dart';

class AcceptRejectButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const AcceptRejectButtons({super.key, required this.onAccept, required this.onReject});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: onReject, icon: const Icon(Icons.close, size: 16), label: const Text('Reject'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)))),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton.icon(onPressed: onAccept, icon: const Icon(Icons.check, size: 16), label: const Text('Accept'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white))),
    ]);
  }
}

