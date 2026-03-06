import 'package:flutter/material.dart';
class SearchFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  const SearchFilters({super.key, required this.onFiltersChanged});
  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}
class _SearchFiltersState extends State<SearchFilters> {
  String _type = 'All';
  double _maxDistance = 10;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: _type, items: ['All', 'UCO', 'Glass', 'Cardboard', 'Plastic', 'Metal'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _type = v!), decoration: InputDecoration(labelText: 'Waste Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
      const SizedBox(height: 12),
      Text('Max Distance: ${_maxDistance.toInt()} km'),
      Slider(value: _maxDistance, min: 1, max: 50, divisions: 49, label: '${_maxDistance.toInt()} km', activeColor: const Color(0xFF0F4C3A), onChanged: (v) => setState(() => _maxDistance = v)),
      ElevatedButton(onPressed: () { widget.onFiltersChanged({'type': _type, 'maxDistance': _maxDistance}); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)), child: const Text('Apply Filters')),
    ]));
  }
}
