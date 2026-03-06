import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: Icons.eco,
      title: 'Turn Waste into Value',
      description: 'Join Kigali\'s circular economy and make a difference',
      color: const Color(0xFF0F4C3A),
    ),
    OnboardingPage(
      image: Icons.hotel,
      title: 'For Hotels',
      description: 'List your waste and earn revenue',
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      image: Icons.factory,
      title: 'For Recyclers',
      description: 'Source quality materials directly',
      color: const Color(0xFF059669),
    ),
    OnboardingPage(
      image: Icons.local_shipping,
      title: 'For Drivers',
      description: 'Earn by collecting recyclables',
      color: const Color(0xFF047857),
    ),
    OnboardingPage(
      image: Icons.star,
      title: 'Features Overview',
      description: 'Offline Mode • Live Tracking • Instant Payments • Green Scores',
      color: const Color(0xFF065F46),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                PageViewDotIndicator(
                  currentItem: _currentPage,
                  count: _pages.length,
                  unselectedColor: Colors.grey.shade300,
                  selectedColor: const Color(0xFF0F4C3A),
                  size: const Size(10, 10),
                ),
                const SizedBox(height: 20),
                if (_currentPage == _pages.length - 1)
                  _buildActionButtons()
                else
                  _buildSkipButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Container(
      color: page.color,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                page.image,
                size: 120,
                color: Colors.white,
              ).animate().fadeIn().scale(),
              const SizedBox(height: 40),
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 20),
              Text(
                page.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        _pageController.animateToPage(
          _pages.length - 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: const Text(
        'Skip',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F4C3A),
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final IconData image;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });
}