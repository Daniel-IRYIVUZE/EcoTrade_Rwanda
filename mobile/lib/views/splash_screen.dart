import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'dashboard/driver_dashboard.dart';
import 'dashboard/hotel_dashboard.dart';
import 'dashboard/recycler_dashboard.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: _buildSplashContent(),
      nextScreen: const SplashDecision(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: const Color(0xFF0F4C3A),
      duration: 3000,
    );
  }

  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo (replace with your local image)
        Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.recycling,
            size: 80,
            color: Color(0xFF0F4C3A),
          ),
        ),
        const SizedBox(height: 20),
        // Loading animation
        const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Version 1.0.0',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class SplashDecision extends StatefulWidget {
  const SplashDecision({super.key});

  @override
  State<SplashDecision> createState() => _SplashDecisionState();
}

class _SplashDecisionState extends State<SplashDecision> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    final String? userRole = prefs.getString('userRole');

    if (!mounted) return;

    if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (!isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Navigate based on role
      Widget dashboard;
      switch (userRole) {
        case 'driver':
          dashboard = const DriverDashboard();
          break;
        case 'hotel':
          dashboard = const HotelDashboard();
          break;
        case 'recycler':
          dashboard = const RecyclerDashboard();
          break;
        default:
          dashboard = const LoginScreen();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}