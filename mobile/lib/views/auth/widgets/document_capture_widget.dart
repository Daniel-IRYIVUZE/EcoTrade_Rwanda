import 'package:flutter/material.dart';

class DocumentCaptureWidget extends StatefulWidget {
  final void Function(String path)? onCapture;
  const DocumentCaptureWidget({super.key, this.onCapture});
  @override
  State<DocumentCaptureWidget> createState() => _DocumentCaptureWidgetState();
}

class _DocumentCaptureWidgetState extends State<DocumentCaptureWidget> {
  String? _capturedPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _capture,
      child: Container(
        width: double.infinity, height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0F4C3A), style: BorderStyle.solid),
        ),
        child: _capturedPath == null
            ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.camera_alt_outlined, color: Color(0xFF0F4C3A), size: 32),
                SizedBox(height: 8),
                Text('Tap to capture document', style: TextStyle(color: Color(0xFF6B7280))),
              ])
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text('Document captured', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ]),
      ),
    );
  }

  Future<void> _capture() async {
    // Simplified - in production use camera plugin
    setState(() => _capturedPath = '/tmp/document.jpg');
    widget.onCapture?.call('/tmp/document.jpg');
  }
}
