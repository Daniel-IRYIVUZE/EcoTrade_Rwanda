import 'package:flutter/material.dart';

class WasteTypeSelector extends StatefulWidget {
  final Function(String) onSelected;
  const WasteTypeSelector({super.key, required this.onSelected});

  @override
  State<WasteTypeSelector> createState() => _WasteTypeSelectorState();
}

class _WasteTypeSelectorState extends State<WasteTypeSelector> {
  String _selected = 'UCO';
  static const List<Map<String, Object>> _types = [
    {'label': 'UCO', 'icon': Icons.water_drop, 'color': Color(0xFFF59E0B)},
    {'label': 'Glass', 'icon': Icons.wine_bar, 'color': Color(0xFF3B82F6)},
    {'label': 'Cardboard', 'icon': Icons.inventory_2, 'color': Color(0xFF92400E)},
    {'label': 'Plastic', 'icon': Icons.cleaning_services, 'color': Color(0xFF10B981)},
    {'label': 'Metal', 'icon': Icons.settings, 'color': Color(0xFF6B7280)},
    {'label': 'Organic', 'icon': Icons.eco, 'color': Color(0xFF0F4C3A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((type) {
        final label = type['label'] as String;
        final icon = type['icon'] as IconData;
        final color = type['color'] as Color;
        final isSelected = _selected == label;

        return GestureDetector(
          onTap: () {
            setState(() => _selected = label);
            widget.onSelected(label);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: color, width: 2) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? color : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : const Color(0xFF374151),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

