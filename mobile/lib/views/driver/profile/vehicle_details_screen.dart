import 'package:flutter/material.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vehicle Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ...[('Type', 'Pickup Truck'), ('Plate Number', 'RAD 123 B'), ('Capacity', '2.5 tons'), ('Year', '2020'), ('Color', 'White')].map((row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(row.$1, style: const TextStyle(color: Color(0xFF6B7280))), Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w500))]),
          )),
        ]))),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)), child: const Text('Update Vehicle Details')),
      ]),
    );
  }
}


