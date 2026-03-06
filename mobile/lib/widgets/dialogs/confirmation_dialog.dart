import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, {
    required String title, required String message,
    String confirmLabel = 'Confirm', Color? confirmColor, VoidCallback? onConfirm,
  }) => showDialog<bool>(context: context, builder: (_) => ConfirmationDialog(
    title: title, message: message, confirmLabel: confirmLabel,
    confirmColor: confirmColor, onConfirm: onConfirm,
  ));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
        ElevatedButton(
          onPressed: () { Navigator.pop(context, true); onConfirm?.call(); },
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor ?? const Color(0xFF0F4C3A)),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
