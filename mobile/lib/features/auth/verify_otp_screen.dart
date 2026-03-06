import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../shared/widgets/eco_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verify();
    }
  }

  void _verify() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.hotelHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              '✉️',
              style: TextStyle(fontSize: 48),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 20),
            const Text(
              'Check your inbox',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit verification code to\nyour email and phone number.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // OTP Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onChanged: (value) => _onDigitEntered(index, value),
                  ),
                );
              }),
            ).animate().slideY(begin: 0.3, duration: 400.ms).fadeIn(),

            const SizedBox(height: 32),

            EcoButton(
              label: 'Verify',
              onPressed: _verify,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 20),

            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: "Didn't receive it? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
