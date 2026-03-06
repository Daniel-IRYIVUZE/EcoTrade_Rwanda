import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SuccessDialog({super.key, this.title = 'Success!', required this.message, this.actionLabel, this.onAction});

  static Future<void> show(BuildContext context, String message, {String title = 'Success!', String? actionLabel, VoidCallback? onAction}) =>
      showDialog(context: context, builder: (_) => SuccessDialog(title: title, message: message, actionLabel: actionLabel, onAction: onAction));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, size: 84, color: Color(0xFF10B981)),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280))),
        if (actionLabel != null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); onAction?.call(); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A)),
            child: Text(actionLabel!),
          ),
        ],
      ]),
    );
  }
}
