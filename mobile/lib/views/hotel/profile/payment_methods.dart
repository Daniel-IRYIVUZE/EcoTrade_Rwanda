import 'package:flutter/material.dart';
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Payment Methods'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [...[('MTN Mobile Money', '250 7XX XXX XXX', true), ('Airtel Money', '250 7XX XXX XXY', false)].map((pm) => Card(margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFFFCC00), child: Icon(Icons.phone_android, color: Colors.white)), title: Text(pm.$1, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(pm.$2), trailing: pm.$3 ? const Chip(label: Text('Primary'), backgroundColor: Color(0xFFD1FAE5)) : null))), const SizedBox(height: 12), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Payment Method'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)))]));
  }
}

