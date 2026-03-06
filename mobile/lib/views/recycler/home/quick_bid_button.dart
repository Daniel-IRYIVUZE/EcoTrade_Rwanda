import 'package:flutter/material.dart';
class QuickBidButton extends StatelessWidget {
  final VoidCallback onPressed;
  const QuickBidButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.bolt), label: const Text('Quick Bid on Available Waste'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}
