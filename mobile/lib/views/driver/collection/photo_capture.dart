import 'package:flutter/material.dart';

class PhotoCaptureWidget extends StatelessWidget {
  final Function(String) onPhotoCaptured;
  const PhotoCaptureWidget({super.key, required this.onPhotoCaptured});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.camera_alt, size: 48, color: Color(0xFF6B7280)),
        const SizedBox(height: 8),
        const Text('Tap to capture waste photo', style: TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => onPhotoCaptured('photo_${DateTime.now().millisecondsSinceEpoch}.jpg'),
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text('Take Photo'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
        ),
      ]),
    );
  }
}


