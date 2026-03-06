import 'package:flutter/material.dart';
class QualitySlider extends StatefulWidget {
  final Function(double) onChanged;
  const QualitySlider({super.key, required this.onChanged});
  @override
  State<QualitySlider> createState() => _QualitySliderState();
}
class _QualitySliderState extends State<QualitySlider> {
  double _quality = 3;
  final List<String> _labels = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quality: ${_labels[(_quality - 1).toInt()]}', style: const TextStyle(fontWeight: FontWeight.bold)),
      Slider(value: _quality, min: 1, max: 5, divisions: 4, label: _labels[(_quality - 1).toInt()], activeColor: const Color(0xFF0F4C3A), onChanged: (v) { setState(() => _quality = v); widget.onChanged(v); }),
    ]);
  }
}

