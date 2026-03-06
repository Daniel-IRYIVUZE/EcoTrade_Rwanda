import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool fullscreen;

  const LoadingIndicator({super.key, this.message, this.fullscreen = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Color(0xFF0F4C3A)),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ],
    );
    if (fullscreen) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: content),
      );
    }
    return Center(child: content);
  }
}
