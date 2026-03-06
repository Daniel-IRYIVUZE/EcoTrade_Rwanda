import 'package:flutter/material.dart';
import '../../models/driver_model.dart';

class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback? onTap;
  const DriverCard({super.key, required this.driver, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF0F4C3A),
              backgroundImage: driver.photoUrl != null ? NetworkImage(driver.photoUrl!) : null,
              child: driver.photoUrl == null ? Text(driver.fullName.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(driver.vehicleType, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              Row(children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                Text(' ${driver.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text('${driver.totalCollections} trips', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: driver.isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(driver.isAvailable ? 'Available' : 'Busy',
                style: TextStyle(color: driver.isAvailable ? Colors.green : Colors.grey, fontSize: 11)),
            ),
          ]),
        ),
      ),
    );
  }
}
