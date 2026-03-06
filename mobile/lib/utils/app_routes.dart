import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/onboarding_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/verification_screen.dart';
import '../views/dashboard/hotel_dashboard.dart';
import '../views/dashboard/driver_dashboard.dart';
import '../views/dashboard/recycler_dashboard.dart';
import '../views/shared/notifications_screen.dart';
import '../views/shared/chat_screen.dart';
import '../views/shared/about_screen.dart';
import '../views/shared/support_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String hotelDashboard = '/hotel';
  static const String driverDashboard = '/driver';
  static const String recyclerDashboard = '/recycler';
  static const String notifications = '/notifications';
  static const String chat = '/chat';
  static const String about = '/about';
  static const String support = '/support';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    verification: (_) => const VerificationScreen(),
    hotelDashboard: (_) => const HotelDashboard(),
    driverDashboard: (_) => const DriverDashboard(),
    recyclerDashboard: (_) => const RecyclerDashboard(),
    notifications: (_) => const NotificationsScreen(),
    chat: (_) => const ChatScreen(),
    about: (_) => const AboutScreen(),
    support: (_) => const SupportScreen(),
  };
}
