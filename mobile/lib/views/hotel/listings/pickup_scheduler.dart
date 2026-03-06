import 'package:flutter/material.dart';
class PickupScheduler extends StatefulWidget {
  final Function(DateTime) onScheduled;
  const PickupScheduler({super.key, required this.onScheduled});
  @override
  State<PickupScheduler> createState() => _PickupSchedulerState();
}
class _PickupSchedulerState extends State<PickupScheduler> {
  DateTime? _selected;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Schedule Pickup', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30))); if (d != null) { setState(() => _selected = d); widget.onScheduled(d); } }, icon: const Icon(Icons.calendar_today), label: Text(_selected == null ? 'Select Date' : '${_selected!.day}/${_selected!.month}/${_selected!.year}')),
    ]);
  }
}

