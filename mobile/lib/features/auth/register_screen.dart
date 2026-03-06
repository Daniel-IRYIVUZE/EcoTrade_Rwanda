import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../shared/widgets/app_text_field.dart';
import '../shared/widgets/eco_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final int _totalSteps = 6;
  String _selectedRole = '';

  // Step 1 controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Step 2 controllers
  final _businessNameController = TextEditingController();
  final _tinController = TextEditingController();

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      context.go(AppRoutes.verifyOtp);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: _prevStep),
        title: Text('Create Account - Step ${_currentStep + 1} of $_totalSteps'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepProgressBar(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentStep),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _Step1PersonalInfo(
          nameController: _nameController,
          phoneController: _phoneController,
          emailController: _emailController,
          passwordController: _passwordController,
          onNext: _nextStep,
        );
      case 1:
        return _Step2BusinessDetails(
          businessNameController: _businessNameController,
          tinController: _tinController,
          selectedRole: _selectedRole,
          onRoleSelected: (role) => setState(() => _selectedRole = role),
          onNext: _nextStep,
        );
      case 2:
        return _Step3Documents(onNext: _nextStep);
      case 3:
        return _Step4Location(onNext: _nextStep);
      case 4:
        return _Step5Terms(onNext: _nextStep);
      case 5:
        return _Step6Verify(onNext: _nextStep);
      default:
        return const SizedBox();
    }
  }
}

// ─── Step Progress Bar ────────────────────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (currentStep + 1) / totalSteps,
      backgroundColor: AppColors.border,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 4,
    );
  }
}

// ─── Step 1: Personal Info ────────────────────────────────────────────────────
class _Step1PersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onNext;

  const _Step1PersonalInfo({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: '👤',
            title: 'Personal Information',
            subtitle: 'Let\'s start with your basic details',
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: phoneController,
            label: 'Phone Number',
            hint: '+250 7XX XXX XXX',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: emailController,
            label: 'Email Address',
            hint: 'your@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: passwordController,
            label: 'Password',
            hint: 'Create a strong password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 32),
          EcoButton(label: 'Continue', onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Step 2: Business Details ──────────────────────────────────────────────────
class _Step2BusinessDetails extends StatelessWidget {
  final TextEditingController businessNameController;
  final TextEditingController tinController;
  final String selectedRole;
  final Function(String) onRoleSelected;
  final VoidCallback onNext;

  const _Step2BusinessDetails({
    required this.businessNameController,
    required this.tinController,
    required this.selectedRole,
    required this.onRoleSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'id': 'hotel', 'label': 'Hotel / Business', 'icon': '🏨', 'color': AppColors.hotelColor},
      {'id': 'recycler', 'label': 'Recycling Company', 'icon': '♻️', 'color': AppColors.recyclerColor},
      {'id': 'driver', 'label': 'Driver / Collector', 'icon': '🚛', 'color': AppColors.driverColor},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: '🏢',
            title: 'Business Details',
            subtitle: 'Tell us about your organization',
          ),
          const SizedBox(height: 28),

          const Text(
            'I am a...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ...roles.map((role) {
            final isSelected = selectedRole == role['id'];
            final color = role['color'] as Color;
            return GestureDetector(
              onTap: () => onRoleSelected(role['id'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.08) : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(role['icon'] as String, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        role['label'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: color, size: 22),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          AppTextField(
            controller: businessNameController,
            label: 'Business / Organization Name',
            hint: 'Enter business name',
            prefixIcon: Icons.business_outlined,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: tinController,
            label: 'TIN Number (optional)',
            hint: 'Tax Identification Number',
            prefixIcon: Icons.numbers_outlined,
          ),
          const SizedBox(height: 32),
          EcoButton(label: 'Continue', onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Step 3: Documents ────────────────────────────────────────────────────────
class _Step3Documents extends StatelessWidget {
  final VoidCallback onNext;
  const _Step3Documents({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: '📄',
            title: 'Upload Documents',
            subtitle: 'We need to verify your identity',
          ),
          const SizedBox(height: 28),

          _DocumentUploadCard(
            title: 'National ID / Passport',
            subtitle: 'Front and back photo',
            icon: Icons.credit_card_outlined,
            isRequired: true,
          ),
          const SizedBox(height: 12),
          _DocumentUploadCard(
            title: 'Business License',
            subtitle: 'Official registration document',
            icon: Icons.description_outlined,
            isRequired: false,
          ),
          const SizedBox(height: 12),
          _DocumentUploadCard(
            title: 'Profile Photo',
            subtitle: 'Clear face photo',
            icon: Icons.camera_alt_outlined,
            isRequired: true,
          ),
          const SizedBox(height: 32),
          EcoButton(label: 'Continue', onPressed: onNext),
        ],
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '*',
                        style: TextStyle(color: AppColors.error, fontSize: 16),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: Location ─────────────────────────────────────────────────────────
class _Step4Location extends StatelessWidget {
  final VoidCallback onNext;
  const _Step4Location({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: '📍',
            title: 'Your Location',
            subtitle: 'Help us find you for pickups and deliveries',
          ),
          const SizedBox(height: 24),

          // Map placeholder
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: const Color(0xFFD4EDDA),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, size: 64, color: AppColors.primary),
                            SizedBox(height: 12),
                            Text(
                              'Map Preview',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.my_location, size: 18),
                    label: const Text('Use My Current Location'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          AppTextField(
            label: 'Address',
            hint: 'Enter your address manually',
            prefixIcon: Icons.location_on_outlined,
          ),
          const Spacer(),
          EcoButton(label: 'Continue', onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Step 5: Terms ────────────────────────────────────────────────────────────
class _Step5Terms extends StatefulWidget {
  final VoidCallback onNext;
  const _Step5Terms({required this.onNext});

  @override
  State<_Step5Terms> createState() => _Step5TermsState();
}

class _Step5TermsState extends State<_Step5Terms> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _StepHeader(
            icon: '📋',
            title: 'Terms & Conditions',
            subtitle: 'Please review and accept to continue',
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: Text(
                  '''Welcome to Ecotrade Platform.

By creating an account, you agree to participate in Kigali's circular economy initiative. 

1. Service Terms
You agree to provide accurate waste listings and engage in fair trade practices.

2. Data Privacy
Your personal and business data is encrypted and protected per GDPR standards.

3. Platform Rules
• No fraudulent listings
• Timely collection completion required
• Transparent pricing expected

4. Payments
All transactions processed securely. Disputes resolved within 5 business days.

5. Environmental Commitment
You commit to proper waste segregation and sustainable practices.''',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _CheckRow(
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v!),
            text: 'I agree to the Terms and Conditions',
            linkText: 'Read',
          ),
          const SizedBox(height: 8),
          _CheckRow(
            value: _privacyAccepted,
            onChanged: (v) => setState(() => _privacyAccepted = v!),
            text: 'I agree to the Privacy Policy',
            linkText: 'Read',
          ),

          const SizedBox(height: 24),
          EcoButton(
            label: 'Agree & Continue',
            onPressed: (_termsAccepted && _privacyAccepted) ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String text;
  final String linkText;

  const _CheckRow({
    required this.value,
    required this.onChanged,
    required this.text,
    required this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              children: [
                TextSpan(text: text),
                TextSpan(
                  text: ' $linkText',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 6: Verify ───────────────────────────────────────────────────────────
class _Step6Verify extends StatelessWidget {
  final VoidCallback onNext;
  const _Step6Verify({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: '✉️',
            title: 'Verify Your Account',
            subtitle: 'Enter the code sent to your phone/email',
          ),
          const SizedBox(height: 40),

          Center(
            child: Column(
              children: [
                Text(
                  'Enter 6-digit code',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // OTP Input row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 46,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          '—',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: const Text('Resend Code'),
                ),
              ],
            ),
          ),

          const Spacer(),
          EcoButton(label: 'Verify & Create Account', onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Step Header ──────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
