import 'package:flutter/material.dart';
export 'revenue_summary_card.dart';

class RevenueSummaryScreen extends StatelessWidget {
  const RevenueSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Revenue Summary'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), body: const Center(child: Text('Revenue data loading...')));
  }
}

