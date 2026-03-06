import 'package:flutter/material.dart';
import '../../../utils/validators.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F4C3A)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _successUI() : _formUI(),
      ),
    );
  }

  Widget _formUI() => Form(
    key: _formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Forgot Password?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Enter your email to receive a reset link', style: TextStyle(color: Color(0xFF6B7280))),
      const SizedBox(height: 32),
      CustomTextField(controller: _emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress, validator: Validators.email, prefix: const Icon(Icons.email_outlined)),
      const SizedBox(height: 24),
      CustomButton(label: 'Send Reset Link', isLoading: _isLoading, onPressed: _send),
    ]),
  );

  Widget _successUI() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF10B981)),
    const SizedBox(height: 20),
    const Text('Email Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text('Check ${_emailCtrl.text}', style: const TextStyle(color: Color(0xFF6B7280))),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
  ]));

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; _sent = true; });
  }

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }
}
