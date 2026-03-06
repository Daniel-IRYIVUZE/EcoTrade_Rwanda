import 'package:flutter/material.dart';
import '../../../widgets/common/custom_button.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F4C3A)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enter Verification Code', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('We sent a 6-digit code to your email/phone', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(6, (i) => SizedBox(
            width: 45, child: TextFormField(
              controller: _ctrls[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0F4C3A), width: 2)),
              ),
              onChanged: (v) { if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus(); },
            ),
          ))),
          const SizedBox(height: 32),
          CustomButton(label: 'Verify', isLoading: _isLoading, onPressed: _verify),
          const SizedBox(height: 16),
          Center(child: TextButton(onPressed: () {}, child: const Text('Resend Code', style: TextStyle(color: Color(0xFF0F4C3A))))),
        ]),
      ),
    );
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }
}
