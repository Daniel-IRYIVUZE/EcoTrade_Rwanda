import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  const ErrorDialog({super.key, this.title = 'Error', required this.message});

  static Future<void> show(BuildContext context, String message, {String title = 'Error'}) =>
      showDialog(context: context, builder: (_) => ErrorDialog(title: title, message: message));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
        const SizedBox(width: 8),
        Text(title),
      ]),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    );
  }
}
