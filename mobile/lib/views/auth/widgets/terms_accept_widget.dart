import 'package:flutter/material.dart';

class TermsAcceptWidget extends StatefulWidget {
  final void Function(bool)? onChanged;
  const TermsAcceptWidget({super.key, this.onChanged});
  @override
  State<TermsAcceptWidget> createState() => _TermsAcceptWidgetState();
}

class _TermsAcceptWidgetState extends State<TermsAcceptWidget> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Checkbox(
        value: _accepted,
        onChanged: (v) { setState(() => _accepted = v ?? false); widget.onChanged?.call(_accepted); },
        activeColor: const Color(0xFF0F4C3A),
      ),
      Expanded(child: RichText(text: const TextSpan(style: TextStyle(color: Color(0xFF374151), fontSize: 13), children: [
        TextSpan(text: 'I agree to the '),
        TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF0F4C3A), fontWeight: FontWeight.bold)),
        TextSpan(text: ' and '),
        TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF0F4C3A), fontWeight: FontWeight.bold)),
      ]))),
    ]);
  }
}
