import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_otp_screen.dart';
import '../../features/hotel/hotel_main_screen.dart';
import '../../features/recycler/recycler_main_screen.dart';
import '../../features/driver/driver_main_screen.dart';
import '../../features/hotel/list_waste_screen.dart';
import '../../features/hotel/bids_screen.dart';
import '../../features/hotel/collections_screen.dart';
import '../../features/hotel/hotel_profile_screen.dart';
import '../../features/recycler/marketplace_screen.dart';
import '../../features/recycler/my_bids_screen.dart';
import '../../features/recycler/fleet_screen.dart';
import '../../features/recycler/recycler_collections_screen.dart';
import '../../features/driver/navigation_screen.dart';
import '../../features/driver/collection_screen.dart';
import '../../features/driver/earnings_screen.dart';
import '../../features/driver/driver_history_screen.dart';
import '../../features/driver/driver_profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';

  // Hotel routes
  static const String hotelHome = '/hotel';
  static const String hotelListWaste = '/hotel/list-waste';
  static const String hotelBids = '/hotel/bids';
  static const String hotelCollections = '/hotel/collections';
  static const String hotelProfile = '/hotel/profile';

  // Recycler routes
  static const String recyclerHome = '/recycler';
  static const String recyclerMarketplace = '/recycler/marketplace';
  static const String recyclerBids = '/recycler/bids';
  static const String recyclerFleet = '/recycler/fleet';
  static const String recyclerCollections = '/recycler/collections';

  // Driver routes
  static const String driverHome = '/driver';
  static const String driverNavigation = '/driver/navigation';
  static const String driverCollection = '/driver/collection';
  static const String driverEarnings = '/driver/earnings';
  static const String driverHistory = '/driver/history';
  static const String driverProfile = '/driver/profile';

  /// Returns the home route for a given user role.
  static String homeForRole(UserRole role) {
    switch (role) {
      case UserRole.business:
        return hotelHome;
      case UserRole.recycler:
        return recyclerHome;
      case UserRole.driver:
        return driverHome;
      default:
        return hotelHome;
    }
  }
}

final _routerKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _routerKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final loc = state.matchedLocation;
      final publicPaths = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.verifyOtp,
      ];
      final isPublic = publicPaths.contains(loc);
      if (!loggedIn && !isPublic) return AppRoutes.login;
      if (loggedIn && (loc == AppRoutes.login || loc == AppRoutes.register)) {
        return AppRoutes.homeForRole(auth.role!);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) => const VerifyOtpScreen(),
      ),

      // ── Business/Hotel Shell ────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => HotelMainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.hotelHome,
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: AppRoutes.hotelListWaste,
            builder: (context, state) => const ListWasteScreen(),
          ),
          GoRoute(
            path: AppRoutes.hotelBids,
            builder: (context, state) => const BidsScreen(),
          ),
          GoRoute(
            path: AppRoutes.hotelCollections,
            builder: (context, state) => const CollectionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.hotelProfile,
            builder: (context, state) => const HotelProfileScreen(),
          ),
        ],
      ),

      // ── Recycler Shell ─────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => RecyclerMainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.recyclerHome,
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: AppRoutes.recyclerMarketplace,
            builder: (context, state) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: AppRoutes.recyclerBids,
            builder: (context, state) => const MyBidsScreen(),
          ),
          GoRoute(
            path: AppRoutes.recyclerFleet,
            builder: (context, state) => const FleetScreen(),
          ),
          GoRoute(
            path: AppRoutes.recyclerCollections,
            builder: (context, state) => const RecyclerCollectionsScreen(),
          ),
        ],
      ),

      // ── Driver Shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => DriverMainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.driverHome,
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: AppRoutes.driverNavigation,
            builder: (context, state) => const NavigationScreen(),
          ),
          GoRoute(
            path: AppRoutes.driverCollection,
            builder: (context, state) => const CollectionScreen(),
          ),
          GoRoute(
            path: AppRoutes.driverEarnings,
            builder: (context, state) => const EarningsScreen(),
          ),
          GoRoute(
            path: AppRoutes.driverHistory,
            builder: (context, state) => const DriverHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.driverProfile,
            builder: (context, state) => const DriverProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
