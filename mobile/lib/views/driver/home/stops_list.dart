import 'package:flutter/material.dart';

class StopsList extends StatelessWidget {
  final List<Map<String, dynamic>> stops;
  final Function(String) onStopTap;
  const StopsList({super.key, required this.stops, required this.onStopTap});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: stops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = stops[i];
        final isCompleted = s['status'] == 'completed';
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCompleted ? Colors.green.shade100 : const Color(0xFF0F4C3A).withValues(alpha: 0.1),
              child: Icon(isCompleted ? Icons.check_circle : Icons.location_on, color: isCompleted ? Colors.green.shade700 : const Color(0xFF0F4C3A)),
            ),
            title: Text(s['hotel'] ?? 'Hotel', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${s['waste']} • ${s['volume']} kg • ${s['time']}'),
            trailing: isCompleted ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => onStopTap(s['id']),
          ),
        );
      },
    );
  }
}


