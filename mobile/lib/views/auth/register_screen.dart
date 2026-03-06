import 'package:flutter/material.dart';
import '../../../utils/validators.dart';
import '../../../utils/app_routes.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'hotel';
  bool _isLoading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F4C3A)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Join Ecotrade', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Connect with Kigali\'s circular economy', style: TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 24),
            // Role selection
            const Text('I am a:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(children: [
              for (final r in ['hotel', 'recycler', 'driver'])
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r.toUpperCase()),
                    selected: _role == r,
                    onSelected: (_) => setState(() => _role = r),
                    selectedColor: const Color(0xFF0F4C3A),
                    labelStyle: TextStyle(color: _role == r ? Colors.white : const Color(0xFF374151)),
                  ),
                )),
            ]),
            const SizedBox(height: 20),
            CustomTextField(controller: _nameCtrl, label: 'Full Name', validator: (v) => Validators.required(v, 'Name'), prefix: const Icon(Icons.person_outline)),
            const SizedBox(height: 16),
            CustomTextField(controller: _emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress, validator: Validators.email, prefix: const Icon(Icons.email_outlined)),
            const SizedBox(height: 16),
            CustomTextField(controller: _phoneCtrl, label: 'Phone', keyboardType: TextInputType.phone, validator: Validators.phone, prefix: const Icon(Icons.phone_outlined)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordCtrl,
              label: 'Password',
              obscureText: _obscure,
              validator: Validators.password,
              prefix: const Icon(Icons.lock_outline),
              suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'Create Account', isLoading: _isLoading, onPressed: _submit),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? '),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Login', style: TextStyle(color: Color(0xFF0F4C3A), fontWeight: FontWeight.bold))),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) Navigator.pushNamed(context, AppRoutes.verification);
  }

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }
}
