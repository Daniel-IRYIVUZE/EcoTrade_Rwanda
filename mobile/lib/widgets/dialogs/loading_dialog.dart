import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  const LoadingDialog({super.key, this.message = 'Please wait...'});

  static void show(BuildContext context, {String message = 'Please wait...'}) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => LoadingDialog(message: message));
  }

  static void hide(BuildContext context) => Navigator.of(context, rootNavigator: true).pop();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(children: [
          const CircularProgressIndicator(color: Color(0xFF0F4C3A)),
          const SizedBox(width: 16),
          Text(message),
        ]),
      ),
    );
  }
}
