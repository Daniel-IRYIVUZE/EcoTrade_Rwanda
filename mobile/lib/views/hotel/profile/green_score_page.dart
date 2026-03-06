import 'package:flutter/material.dart';

class GreenScorePage extends StatelessWidget {
  const GreenScorePage({super.key});

  static const List<Map<String, Object>> _stats = [
    {
      'title': 'Waste Listed',
      'current': 150,
      'total': 200,
      'subtitle': 'Completion Rate 75%',
    },
    {
      'title': 'Collections Completed',
      'current': 45,
      'total': 50,
      'subtitle': 'Completion Rate 90%',
    },
    {
      'title': 'Bids Accepted Within 24h',
      'current': 38,
      'total': 45,
      'subtitle': 'Completion Rate 84%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Score'),
        backgroundColor: const Color(0xFF0F4C3A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFF0F4C3A),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Your Green Score',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    '750 pts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gold Partner Level',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._stats.map((stat) {
            final current = stat['current'] as int;
            final total = stat['total'] as int;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: current / total,
                      color: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFFF3F4F6),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['subtitle'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

