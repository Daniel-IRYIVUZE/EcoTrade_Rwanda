import 'package:flutter/material.dart';

class FilterSidebar extends StatelessWidget {
  final List<Widget> filters;
  final VoidCallback? onApply;
  final VoidCallback? onClear;
  const FilterSidebar({super.key, required this.filters, this.onApply, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: onClear, child: const Text('Clear All', style: TextStyle(color: Color(0xFFEF4444)))),
            ]),
          ),
          const Divider(),
          Expanded(child: ListView(padding: const EdgeInsets.all(16), children: filters)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); onApply?.call(); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), minimumSize: const Size(double.infinity, 48)),
              child: const Text('Apply Filters'),
            ),
          ),
        ]),
      ),
    );
  }
}
