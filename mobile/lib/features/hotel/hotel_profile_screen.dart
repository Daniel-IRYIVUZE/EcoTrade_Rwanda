import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../shared/widgets/shared_cards.dart';

class HotelProfileScreen extends ConsumerWidget {
  const HotelProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.business, size: 38, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.displayName ?? 'Hotel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kigali City • Verified ✓',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Green Score
                GreenScoreCard(
                  score: (user?.greenScore ?? 0).toDouble(),
                  level: _scoreLevel(user?.greenScore ?? 0),
                ).animate().slideY(begin: 0.2, duration: 300.ms).fadeIn(),

                const SizedBox(height: 20),

                // Business Details
                _ProfileSection(
                  title: 'Business Details',
                  children: [
                    _ProfileRow(icon: Icons.business_outlined, label: 'Business Name', value: user?.displayName ?? 'N/A'),
                    _ProfileRow(icon: Icons.numbers_outlined, label: 'TIN Number', value: '119874652'),
                    _ProfileRow(icon: Icons.location_on_outlined, label: 'Location', value: 'KN 5 Rd, Kigali'),
                    _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? 'N/A'),
                    _ProfileRow(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? 'N/A'),
                  ],
                ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 80.ms).fadeIn(),

                const SizedBox(height: 16),

                // Payment Methods
                _ProfileSection(
                  title: 'Payment Methods',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Add'),
                  ),
                  children: [
                    _PaymentMethodCard(
                      icon: '📱',
                      name: 'MTN Mobile Money',
                      detail: '+250 788 *** 456',
                      isDefault: true,
                    ),
                    _PaymentMethodCard(
                      icon: '🏦',
                      name: 'Bank of Kigali',
                      detail: '**** **** 8873',
                      isDefault: false,
                    ),
                  ],
                ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 160.ms).fadeIn(),

                const SizedBox(height: 16),

                // Settings
                _ProfileSection(
                  title: 'Settings',
                  children: [
                    _SettingRow(icon: Icons.notifications_outlined, label: 'Notifications'),
                    _SettingRow(icon: Icons.language_outlined, label: 'Language', trailing: const Text('English')),
                    _SettingRow(icon: Icons.dark_mode_outlined, label: 'Dark Mode'),
                    _SettingRow(icon: Icons.lock_outline, label: 'Change Password'),
                  ],
                ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 240.ms).fadeIn(),

                const SizedBox(height: 16),

                // Support
                _ProfileSection(
                  title: 'Support',
                  children: [
                    _SettingRow(icon: Icons.help_outline, label: 'Help & FAQ'),
                    _SettingRow(icon: Icons.support_agent_outlined, label: 'Contact Support'),
                    _SettingRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy'),
                  ],
                ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 320.ms).fadeIn(),

                const SizedBox(height: 16),

                // Logout
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _scoreLevel(int score) {
    if (score >= 90) return 'Eco Master';
    if (score >= 75) return 'Eco Champion';
    if (score >= 55) return 'Eco Starter';
    return 'Eco Beginner';
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _ProfileSection({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String icon;
  final String name;
  final String detail;
  final bool isDefault;

  const _PaymentMethodCard({
    required this.icon,
    required this.name,
    required this.detail,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _SettingRow({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
