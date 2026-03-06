import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  const TransactionList({super.key, required this.transactions});
  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No transactions found', style: TextStyle(color: Color(0xFF6B7280)))));
    }
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = transactions[i];
        return ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0xFF0F4C3A).withValues(alpha: 0.1), child: const Icon(Icons.monetization_on, color: Color(0xFF0F4C3A))),
          title: Text(t['description'] ?? 'Payment', style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(t['date'] ?? ''),
          trailing: Text('RWF ${t['amount'] ?? 0}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}


